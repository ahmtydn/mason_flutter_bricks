import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name.snakeCase()}}/l10n/gen/app_localizations.dart';
import 'package:{{project_name.snakeCase()}}/product/init/theme/app_theme.dart';
import 'package:{{project_name.snakeCase()}}/product/l10n/gen/app_localizations.dart';
import 'package:{{project_name.snakeCase()}}/product/l10n/language_initializer.dart';
import 'package:{{project_name.snakeCase()}}/product/navigation/app_router.dart';
import 'package:{{project_name.snakeCase()}}/product/service/container/product_container.dart';
import 'package:{{project_name.snakeCase()}}/product/state/product_state.dart';
import 'package:{{project_name.snakeCase()}}/product/state/product_view_model.dart';

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = ProductContainer.read<AppRouter>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductViewModel>.value(
          value: ProductContainer.read<ProductViewModel>(),
        ),
      ],
      child: BlocBuilder<ProductViewModel, ProductState>(
        builder: (context, state) {
          return MaterialApp.router(
            routerConfig: router.config(),
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            locale: state.locale,
            localizationsDelegates: LanguageInitializer.delegates,
            supportedLocales: LanguageInitializer.supportedLocales,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            builder: (context, child) {
              final localizations = AppLocalizations.of(context);
              final locale = Localizations.localeOf(context);
              AppLocalizationService.initialize(localizations, locale);
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
