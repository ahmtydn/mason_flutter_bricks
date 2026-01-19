import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/product/state/base/base_cubit.dart';
import 'package:{{project_name.snakeCase()}}/product/state/product_state.dart';

class ProductViewModel extends BaseCubit<ProductState> {
  ProductViewModel() : super(const ProductState());

  void changeTheme(ThemeMode mode) {
    emitSafe(state.copyWith(themeMode: mode));
  }

  void toggleTheme(BuildContext context) {
    final currentBrightness = state.themeMode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (state.themeMode == ThemeMode.dark
              ? Brightness.dark
              : Brightness.light);

    final nextMode = currentBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    changeTheme(nextMode);
  }

  void changeLocale(Locale locale) {
    emitSafe(state.copyWith(locale: locale));
  }

  void toggleLocale() {
    final currentLocale = state.locale?.languageCode ?? 'en';
    final nextLocale = currentLocale == 'en'
        ? const Locale('tr')
        : const Locale('en');
    changeLocale(nextLocale);
  }
}
