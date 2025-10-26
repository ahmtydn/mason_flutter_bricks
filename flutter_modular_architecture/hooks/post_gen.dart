import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final projectName = context.vars['project_name'] as String;
  final organizationName = context.vars['organization_name'] as String;
  final platforms = context.vars['platforms'] as List;

  logger.info('🚀 Setting up Flutter modular architecture project...');
  logger.info('📦 Project: $projectName');
  logger.info('🏢 Organization: $organizationName');
  logger.info('🎯 Platforms: ${platforms.join(', ')}');

  // Create platform directories based on selection
  for (final platform in platforms) {
    final platformName = platform.toString();
    logger.info('Creating $platformName platform...');

    final progress = logger.progress('Setting up $platformName');

    try {
      // Run flutter create for each platform
      final result = await Process.run('flutter', [
        'create',
        '--platforms=$platformName',
        '--org=$organizationName',
        '--project-name=${_toSnakeCase(projectName)}',
        '.',
      ], workingDirectory: Directory.current.path);

      if (result.exitCode == 0) {
        progress.complete('✅ $platformName platform created');
      } else {
        progress.fail('❌ Failed to create $platformName platform');
        logger.err(result.stderr.toString());
      }
    } catch (e) {
      progress.fail('❌ Error creating $platformName platform');
      logger.err(e.toString());
    }
  }

  logger.success('🎉 Project setup completed!');
  logger.info('');
  logger.info('Next steps:');
  logger.info('  1. cd ${_toSnakeCase(projectName)}');
  logger.info('  2. chmod +x script/*.sh');
  logger.info('  3. ./script/pub.sh');
  logger.info('  4. ./script/build.sh build');
  logger.info('  5. flutter run');
}

String _toSnakeCase(String text) {
  return text
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      )
      .replaceAll(RegExp(r'^_'), '')
      .replaceAll(RegExp(r'[^\w]+'), '_')
      .toLowerCase();
}
