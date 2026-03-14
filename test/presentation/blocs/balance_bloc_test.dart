import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:btgfundsmanager/domain/repositories/transaction_repository.dart';
import 'package:btgfundsmanager/domain/entities/user_balance.dart';
import 'package:btgfundsmanager/presentation/blocs/balance_bloc.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockTxRepo;
  late BalanceBloc balanceBloc;

  setUp(() {
    mockTxRepo = MockTransactionRepository();
    // Instanciar Bloc inyectando Mock
    balanceBloc = BalanceBloc(transactionRepository: mockTxRepo);
  });

  tearDown(() {
    balanceBloc.close();
  });

  group('BalanceBloc Tests -', () {
    test('Initial state is BalanceInitial', () {
      expect(balanceBloc.state, isA<BalanceInitial>());
    });

    blocTest<BalanceBloc, BalanceState>(
      'emits [BalanceLoading, BalanceLoaded] when LoadBalance is successful',
      build: () {
        when(() => mockTxRepo.getUserBalance()).thenAnswer((_) async => const UserBalance(amount: 500000.0));
        return balanceBloc;
      },
      act: (bloc) => bloc.add(LoadBalance()),
      expect: () => [
        isA<BalanceLoading>(),
        isA<BalanceLoaded>(),
      ],
      verify: (bloc) {
        expect((bloc.state as BalanceLoaded).balance.amount, 500000.0);
      }
    );
  });
}
