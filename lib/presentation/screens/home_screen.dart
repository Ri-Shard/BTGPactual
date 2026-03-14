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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

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
          padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fideicomisos y Fondos BTG',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildSearchBar()),
                        const SizedBox(width: 8),
                        _buildNotifications(),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.settings_outlined,
                          color: AppColors.slate600,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                )
              else
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
                        _buildSearchBar(),
                        const SizedBox(width: 24),
                        _buildNotifications(),
                        const SizedBox(width: 24),
                        const Icon(
                          Icons.settings_outlined,
                          color: AppColors.slate600,
                          size: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              SizedBox(height: isMobile ? 24 : 32),

              if (isMobile)
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BalanceCard(),
                    SizedBox(height: 16),
                    AccountSummaryCard(),
                  ],
                )
              else
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: BalanceCard()),
                    SizedBox(width: 24),
                    Expanded(flex: 1, child: AccountSummaryCard()),
                  ],
                ),

              SizedBox(height: isMobile ? 32 : 48),

              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fondos Disponibles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore nuestras opciones de inversión curadas',
                      style: TextStyle(color: AppColors.slate500, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: const Row(
                        children: [
                          _FilterChip(label: 'Todos', isSelected: true),
                          SizedBox(width: 8),
                          _FilterChip(label: 'FPV'),
                          SizedBox(width: 8),
                          _FilterChip(label: 'FIC'),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fondos Disponibles',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.slate900,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Explore nuestras opciones de inversión curadas',
                          style: TextStyle(
                            color: AppColors.slate500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        _FilterChip(label: 'Todos', isSelected: true),
                        SizedBox(width: 8),
                        _FilterChip(label: 'FPV'),
                        SizedBox(width: 8),
                        _FilterChip(label: 'FIC'),
                      ],
                    ),
                  ],
                ),
              SizedBox(height: isMobile ? 16 : 24),

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
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: isMobile ? 500 : 350,
                        crossAxisSpacing: isMobile ? 16 : 24,
                        mainAxisSpacing: isMobile ? 16 : 24,
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

  Widget _buildSearchBar() {
    return Container(
      width: 250,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.search, size: 20, color: AppColors.slate400),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Buscar fondos...',
              style: TextStyle(color: AppColors.slate500, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    return Stack(
      children: [
        const Icon(
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
