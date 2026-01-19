import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final projectName = context.vars['project_name'] as String;
  final organizationName = context.vars['organization_name'] as String;

  // Handle platforms as either List (interactive mode) or String (CLI mode)
  final platformsVar = context.vars['platforms'];
  final platforms = platformsVar is List
      ? platformsVar
      : (platformsVar as String).split(',').map((e) => e.trim()).toList();

  _logProjectSetupInfo(logger, projectName, organizationName, platforms);

  await _setupPlatforms(logger, projectName, organizationName, platforms);
  await _generateLocalizations(logger);
  await _buildMainProject(logger);
  await _buildModuleGenIfExists(logger);

  if (platforms.contains('macos')) {
    await _enableMacOSNetworkAccess(logger: logger);
  }

  // Set application display name
  final appName = context.vars['app_name'] as String? ?? projectName;
  await _setAppDisplayName(logger, appName);

  await _runDartFix(logger);

  logger.success('🎉 Project setup completed!');
}

void _logProjectSetupInfo(
  Logger logger,
  String projectName,
  String organizationName,
  List platforms,
) {
  logger.info('🚀 Setting up Flutter modular architecture project...');
  logger.info('📦 Project: $projectName');
  logger.info('🏢 Organization: $organizationName');
  logger.info('🎯 Platforms: ${platforms.join(', ')}');
}

Future<void> _setupPlatforms(
  Logger logger,
  String projectName,
  String organizationName,
  List platforms,
) async {
  for (final platform in platforms) {
    await _createPlatform(
      logger: logger,
      platform: platform.toString(),
      projectName: projectName,
      organizationName: organizationName,
    );
  }
}

Future<void> _createPlatform({
  required Logger logger,
  required String platform,
  required String projectName,
  required String organizationName,
}) async {
  logger.info('Creating $platform platform...');
  final progress = logger.progress('Setting up $platform');

  final result = await _executeFlutterCommand([
    'create',
    '--platforms=$platform',
    '--org=$organizationName',
    '--project-name=${_toSnakeCase(projectName)}',
    '.',
  ], workingDirectory: Directory.current.path);

  if (result.success) {
    progress.complete('$platform platform created');
  } else {
    progress.fail('Failed to create $platform platform');
    _logCommandError(logger, result);
  }
}

Future<void> _generateLocalizations(Logger logger) async {
  final progress = logger.progress('Running flutter gen-l10n');

  final result = await _executeFlutterCommand([
    'gen-l10n',
  ], workingDirectory: Directory.current.path);

  if (result.success) {
    progress.complete('Localization generated');
  } else {
    progress.fail('Failed to run flutter gen-l10n');
    _logCommandError(logger, result);
  }
}

Future<void> _buildMainProject(Logger logger) async {
  await _runBuildRunner(
    logger: logger,
    targetName: 'main project',
    directory: Directory.current,
  );
}

Future<void> _buildModuleGenIfExists(Logger logger) async {
  final moduleGenDirectory = Directory('${Directory.current.path}/module/gen');

  if (!moduleGenDirectory.existsSync()) {
    logger.warn('module/gen package not found, skipping build_runner.');
    return;
  }

  await _runBuildRunner(
    logger: logger,
    targetName: 'module/gen',
    directory: moduleGenDirectory,
  );
}

Future<void> _runBuildRunner({
  required Logger logger,
  required String targetName,
  required Directory directory,
}) async {
  if (!await _runPubGet(logger, targetName, directory)) {
    return;
  }

  await _runCodeGeneration(logger, targetName, directory);
}

Future<bool> _runPubGet(
  Logger logger,
  String targetName,
  Directory directory,
) async {
  final progress = logger.progress('Running flutter pub get for $targetName');

  final result = await _executeFlutterCommand([
    'pub',
    'get',
  ], workingDirectory: directory.path);

  if (result.success) {
    progress.complete('flutter pub get finished for $targetName');
    return true;
  } else {
    progress.fail('flutter pub get failed for $targetName');
    _logCommandError(logger, result, context: 'flutter pub get ($targetName)');
    return false;
  }
}

Future<void> _runCodeGeneration(
  Logger logger,
  String targetName,
  Directory directory,
) async {
  final progress = logger.progress('Running build_runner for $targetName');

  final result = await _executeFlutterCommand([
    'pub',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ], workingDirectory: directory.path);

  if (result.success) {
    progress.complete('build_runner finished for $targetName');
  } else {
    progress.fail('build_runner failed for $targetName');
    _logCommandError(
      logger,
      result,
      context: 'flutter pub run build_runner build ($targetName)',
    );
  }
}

Future<void> _runDartFix(Logger logger) async {
  final progress = logger.progress('Running dart fix --apply');

  final result = await _executeDartCommand([
    'fix',
    '--apply',
  ], workingDirectory: Directory.current.path);

  if (result.success) {
    progress.complete('dart fix --apply completed');
  } else {
    progress.fail('dart fix --apply failed');
    _logCommandError(logger, result, context: 'dart fix --apply');
  }
}

Future<_CommandResult> _executeFlutterCommand(
  List<String> arguments, {
  required String workingDirectory,
}) async {
  try {
    final result = await Process.run(
      'flutter',
      arguments,
      workingDirectory: workingDirectory,
    );

    return _CommandResult(
      success: result.exitCode == 0,
      exitCode: result.exitCode,
      stdout: result.stdout?.toString() ?? '',
      stderr: result.stderr?.toString() ?? '',
    );
  } catch (e) {
    return _CommandResult(
      success: false,
      exitCode: -1,
      stdout: '',
      stderr: e.toString(),
    );
  }
}

Future<_CommandResult> _executeDartCommand(
  List<String> arguments, {
  required String workingDirectory,
}) async {
  try {
    final result = await Process.run(
      'dart',
      arguments,
      workingDirectory: workingDirectory,
    );

    return _CommandResult(
      success: result.exitCode == 0,
      exitCode: result.exitCode,
      stdout: result.stdout?.toString() ?? '',
      stderr: result.stderr?.toString() ?? '',
    );
  } catch (e) {
    return _CommandResult(
      success: false,
      exitCode: -1,
      stdout: '',
      stderr: e.toString(),
    );
  }
}

void _logCommandError(Logger logger, _CommandResult result, {String? context}) {
  final command = context ?? 'Command';
  logger.err('$command exited with code ${result.exitCode}');

  final stdout = result.stdout.trim();
  if (stdout.isNotEmpty) {
    logger.err('\nStdout:\n$stdout');
  }

  final stderr = result.stderr.trim();
  if (stderr.isNotEmpty) {
    logger.err('\nStderr:\n$stderr');
  }
}

Future<void> _enableMacOSNetworkAccess({required Logger logger}) async {
  const entitlementsPaths = [
    'macos/Runner/DebugProfile.entitlements',
    'macos/Runner/Release.entitlements',
  ];

  for (final path in entitlementsPaths) {
    await _addNetworkEntitlement(logger, path);
  }
}

Future<void> _addNetworkEntitlement(Logger logger, String relativePath) async {
  final file = File('${Directory.current.path}/$relativePath');

  if (!file.existsSync()) {
    logger.warn('macOS entitlements file not found: $relativePath');
    return;
  }

  try {
    final content = await file.readAsString();

    if (_hasNetworkEntitlement(content)) {
      return;
    }

    final updatedContent = _injectNetworkEntitlement(content);
    await file.writeAsString(updatedContent);
    logger.info('Added network client entitlement to $relativePath');
  } catch (e) {
    logger.warn('Failed to update $relativePath: $e');
  }
}

bool _hasNetworkEntitlement(String content) {
  return content.contains('com.apple.security.network.client');
}

String _injectNetworkEntitlement(String content) {
  return content.replaceFirst(
    '</dict>',
    '\t<key>com.apple.security.network.client</key>\n\t<true/>\n</dict>',
  );
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

class _CommandResult {
  const _CommandResult({
    required this.success,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final bool success;
  final int exitCode;
  final String stdout;
  final String stderr;
}

Future<void> _setAppDisplayName(Logger logger, String appName) async {
  final progress = logger.progress('Updating application display name...');

  await _updateAndroidAppName(appName);
  await _updateIOSAppName(appName);
  await _updateMacOSAppName(appName);
  await _updateWebAppName(appName);
  await _updateWindowsAppName(appName);
  await _updateLinuxAppName(appName);

  progress.complete('Application display name updated to: $appName');
}

Future<void> _updateAndroidAppName(String appName) async {
  final file = File(
    '${Directory.current.path}/android/app/src/main/AndroidManifest.xml',
  );
  if (!file.existsSync()) return;

  try {
    var content = await file.readAsString();
    // Replace android:label="android" or similar with the new name
    // The regex handles the potential attribute variations better
    content = content.replaceAll(
      RegExp(r'android:label="[^"]*"'),
      'android:label="$appName"',
    );
    await file.writeAsString(content);
  } catch (_) {}
}

Future<void> _updateIOSAppName(String appName) async {
  final file = File('${Directory.current.path}/ios/Runner/Info.plist');
  if (!file.existsSync()) return;

  try {
    var content = await file.readAsString();
    // Update CFBundleDisplayName
    // If it exists, replace the value. If not, insert it.
    if (content.contains('<key>CFBundleDisplayName</key>')) {
      content = content.replaceAllMapped(
        RegExp(
          r'(<key>CFBundleDisplayName</key>\s*<string>)(.*?)(</string>)',
          multiLine: true,
          dotAll: true,
        ),
        (match) => '${match.group(1)}$appName${match.group(3)}',
      );
    } else {
      // Insert it after CFBundleName
      content = content.replaceAllMapped(
        RegExp(
          r'(<key>CFBundleName</key>\s*<string>)(.*?)(</string>)',
          multiLine: true,
          dotAll: true,
        ),
        (match) =>
            '${match.group(0)}\n\t<key>CFBundleDisplayName</key>\n\t<string>$appName</string>',
      );
    }
    await file.writeAsString(content);
  } catch (_) {}
}

Future<void> _updateMacOSAppName(String appName) async {
  final file = File(
    '${Directory.current.path}/macos/Runner/Configs/AppInfo.xcconfig',
  );
  if (!file.existsSync()) return;

  try {
    var content = await file.readAsString();
    content = content.replaceAll(
      RegExp(r'PRODUCT_NAME = .*'),
      'PRODUCT_NAME = $appName',
    );
    await file.writeAsString(content);
  } catch (_) {}
}

Future<void> _updateWebAppName(String appName) async {
  final file = File('${Directory.current.path}/web/index.html');
  if (!file.existsSync()) return;

  try {
    var content = await file.readAsString();

    // Update title
    content = content.replaceAll(
      RegExp(r'<title>(.*?)</title>'),
      '<title>$appName</title>',
    );

    // Update apple-mobile-web-app-title
    content = content.replaceAll(
      RegExp(r'<meta name="apple-mobile-web-app-title" content="(.*?)">'),
      '<meta name="apple-mobile-web-app-title" content="$appName">',
    );

    await file.writeAsString(content);
  } catch (_) {}
}

Future<void> _updateWindowsAppName(String appName) async {
  final file = File('${Directory.current.path}/windows/runner/main.cpp');
  if (!file.existsSync()) return;

  try {
    var content = await file.readAsString();
    content = content.replaceAll(
      RegExp(r'window.Create\(L"[^"]*",'),
      'window.Create(L"$appName",',
    );
    await file.writeAsString(content);
  } catch (_) {}
}

Future<void> _updateLinuxAppName(String appName) async {
  final file = File('${Directory.current.path}/linux/my_application.cc');
  if (!file.existsSync()) return;

  try {
    var content = await file.readAsString();
    content = content.replaceAll(
      RegExp(r'gtk_window_set_title\(window, "[^"]*"\);'),
      'gtk_window_set_title(window, "$appName");',
    );
    await file.writeAsString(content);
  } catch (_) {}
}
