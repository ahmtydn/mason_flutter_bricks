import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_widgets/module_widgets.dart';
import 'package:{{project_name.snakeCase()}}/feature/counter/view/widgets/latest_count_card.dart';
import 'package:{{project_name.snakeCase()}}/feature/counter/view_model/counter_state.dart';
import 'package:{{project_name.snakeCase()}}/feature/counter/view_model/counter_view_model.dart';
import 'package:{{project_name.snakeCase()}}/l10n/gen/app_localizations.dart';
import 'package:{{project_name.snakeCase()}}/product/service/container/product_container.dart';
import 'package:{{project_name.snakeCase()}}/product/service/counter/counter_service.dart';
import 'package:{{project_name.snakeCase()}}/product/state/product_state.dart';
import 'package:{{project_name.snakeCase()}}/product/state/product_view_model.dart';
import 'package:{{project_name.snakeCase()}}/product/utility/date_time_formatter.dart';
import 'package:{{project_name.snakeCase()}}/product/widgets/app_error.dart';

@RoutePage()
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final viewModel = CounterViewModel(
          counterService: ProductContainer.read<CounterService>(),
          dateTimeFormatter: ProductContainer.read<DateTimeFormatter>(),
        );
        unawaited(viewModel.initialize());
        return viewModel;
      },
      child: const _CounterViewBody(),
    );
  }
}

class _CounterViewBody extends StatelessWidget {
  const _CounterViewBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<CounterViewModel, CounterState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        if (state.status == CounterStatus.failure) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        context.read<CounterViewModel>().clearError();
      },
      child: BlocBuilder<CounterViewModel, CounterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.counterScreenTitle)),
            body: _CounterBody(state: state, l10n: l10n),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.read<CounterViewModel>().increment(
                note: l10n.counterManualIncrementNote,
              ),
              tooltip: l10n.counterIncrementTooltip,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}

class _CounterBody extends StatelessWidget {
  const _CounterBody({required this.state, required this.l10n});

  final CounterState state;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CounterStatus.failure) {
      return AppError(
        message:
            l10n?.counterErrorMessage(state.errorMessage ?? 'Unknown error') ??
            'Failed to initialize database: '
                '${state.errorMessage ?? 'Unknown error'}',
        onRetry: context.read<CounterViewModel>().initialize,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n?.counterDescription ??
                  'You have pushed the button this many times:',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '${state.total}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            if (state.lastRecordedAt != null)
              LatestCountCard(
                title: l10n?.counterLastRecordedLabel ?? 'Last Recorded',
                timestamp: state.lastRecordedAt!,
                note: state.lastNote,
              )
            else
              Text(
                l10n?.counterNoHistory ?? 'No counter history yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 32),
            BlocBuilder<ProductViewModel, ProductState>(
              builder: (context, productState) {
                final isDark =
                    productState.themeMode == ThemeMode.dark ||
                    (productState.themeMode == ThemeMode.system &&
                        MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark);
                return AppButton(
                  label: isDark ? 'Switch to Light' : 'Switch to Dark',
                  leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () =>
                      context.read<ProductViewModel>().toggleTheme(context),
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<ProductViewModel, ProductState>(
              builder: (context, productState) {
                final currentLocale =
                    productState.locale?.languageCode ??
                    Localizations.localeOf(context).languageCode;
                return AppButton(
                  label: currentLocale == 'en'
                      ? 'Switch to Turkish'
                      : 'Switch to English',
                  leading: const Icon(Icons.language),
                  onPressed: context.read<ProductViewModel>().toggleLocale,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
