import 'package:flutter/material.dart';
import 'package:btgfundsmanager/core/theme/app_colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../blocs/fund_bloc.dart';
import '../blocs/balance_bloc.dart';
import '../blocs/transaction_bloc.dart';

import '../widgets/funds/fund_card.dart';
import '../widgets/home/balance_card.dart';
import '../widgets/home/account_summary_card.dart';
import 'subscription_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showSubscriptionDialog(BuildContext context, fund) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<FundBloc>(),
        child: SubscriptionDialog(fund: fund),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FundBloc, FundState>(
      listener: (context, state) {
        if (state is FundOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          context.read<BalanceBloc>().add(LoadBalance());
          context.read<TransactionBloc>().add(LoadTransactions());
        } else if (state is FundError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<FundBloc>().add(LoadFunds());
          context.read<BalanceBloc>().add(LoadBalance());
          context.read<TransactionBloc>().add(LoadTransactions());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fideicomisos y Fondos BTG',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate900,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.slate300),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 20,
                              color: AppColors.slate400,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Buscar fondos...',
                              style: TextStyle(
                                color: AppColors.slate500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Stack(
                        children: [
                          Icon(
                            Icons.notifications_none,
                            color: AppColors.slate600,
                            size: 28,
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Icon(
                        Icons.settings_outlined,
                        color: AppColors.slate600,
                        size: 28,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 2, child: BalanceCard()),
                  const SizedBox(width: 24),
                  const Expanded(flex: 1, child: AccountSummaryCard()),
                ],
              ),

              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fondos Disponibles',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explore nuestras opciones de inversión curadas',
                        style: TextStyle(
                          color: AppColors.slate500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _FilterChip(label: 'Todos', isSelected: true),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'FPV'),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'FIC'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              BlocBuilder<FundBloc, FundState>(
                builder: (context, state) {
                  if (state is FundLoading || state is FundInitial) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: LoadingAnimationWidget.inkDrop(
                          color: AppColors.primary,
                          size: 50,
                        ),
                      ),
                    );
                  } else if (state is FundLoaded) {
                    final funds = state.availableFunds;
                    final subscribedIds = state.subscribedFunds
                        .map((e) => e.id)
                        .toSet();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 350,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            mainAxisExtent: 420,
                          ),
                      itemCount: funds.length,
                      itemBuilder: (context, index) {
                        final fund = funds[index];
                        final isSubscribed = subscribedIds.contains(fund.id);

                        return FundCard(
                          fund: fund,
                          isSubscribed: isSubscribed,
                          onSubscribe: () =>
                              _showSubscriptionDialog(context, fund),
                          onCancel: () {
                            context.read<FundBloc>().add(
                              CancelSubscription(fundId: fund.id),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text('Algo salió mal cargando los fondos.'),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.slate200 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.slate900 : AppColors.slate600,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
