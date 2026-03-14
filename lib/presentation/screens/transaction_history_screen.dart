import 'package:flutter/material.dart';
import 'package:btgfundsmanager/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../blocs/transaction_bloc.dart';

import '../widgets/history/transaction_header.dart';
import '../widgets/history/transaction_table.dart';
import '../widgets/history/summary_card.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading || state is TransactionInitial) {
          return Center(
            child: LoadingAnimationWidget.inkDrop(
              color: AppColors.primary,
              size: 50,
            ),
          );
        } else if (state is TransactionLoaded) {
          final transactions = state.transactions;

          double totalAbonos = 0;
          double totalRetiros = 0;

          for (var tx in transactions) {
            final isSub = tx.type.toString().contains('subscription');
            if (isSub) {
              totalRetiros += tx.amount;
            } else {
              totalAbonos += tx.amount;
            }
          }
          final balanceNeto = totalAbonos - totalRetiros;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TransactionHeader(),
                const SizedBox(height: 32),
                TransactionTable(transactions: transactions),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'BALANCE NETO',
                        amount: balanceNeto,
                        subtitle: 'Este período (30 días)',
                        isPrimary: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SummaryCard(
                        title: 'TOTAL ABONOS',
                        amount: totalAbonos,
                        indicatorColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SummaryCard(
                        title: 'TOTAL RETIROS',
                        amount: totalRetiros,
                        indicatorColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (state is TransactionError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
