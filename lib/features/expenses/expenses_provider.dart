import 'package:flutter_riverpod/flutter_riverpod.dart';

class Expense {
  final String title;
  final String subtitle;
  final String amount;
  final bool isOwed;
  final bool isPersonal;
  final String category;
  final String date;

  Expense({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isOwed,
    required this.isPersonal,
    required this.category,
    required this.date,
  });
}

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier()
      : super([
          Expense(
            title: 'Chai & Samosa',
            subtitle: 'Office Chai Group • Paid by Aman',
            amount: '₹45.00',
            isOwed: true,
            isPersonal: false,
            category: 'food',
            date: 'Today, 4:30 PM',
          ),
          Expense(
            title: 'Uber ride to Client Office',
            subtitle: 'Personal Log',
            amount: '₹240.00',
            isOwed: false,
            isPersonal: true,
            category: 'travel',
            date: 'Today, 2:15 PM',
          ),
          Expense(
            title: 'Team Lunch (Pizza)',
            subtitle: 'Paid by You • Split equally',
            amount: '₹1,250.00',
            isOwed: false,
            isPersonal: false,
            category: 'food',
            date: 'Yesterday, 1:10 PM',
          ),
          Expense(
            title: 'Monthly Internet subscription',
            subtitle: 'Personal Log',
            amount: '₹799.00',
            isOwed: false,
            isPersonal: true,
            category: 'bills',
            date: '1 Jun 2026',
          ),
          Expense(
            title: 'Printouts & Stationery',
            subtitle: 'Office Admin • Paid by Rohit',
            amount: '₹120.00',
            isOwed: true,
            isPersonal: false,
            category: 'other',
            date: '30 May 2026',
          ),
        ]);

  void addExpense({
    required String title,
    required double amount,
    required String groupName,
    required String category,
    required bool isPersonal,
    required bool isPaidByMe,
    String? payerName,
  }) {
    final amountText = '₹${amount.toStringAsFixed(2)}';
    String subtitleText;
    bool isOwedExpense = false;

    if (isPersonal) {
      subtitleText = 'Personal Log';
    } else {
      if (isPaidByMe) {
        subtitleText = 'Paid by You • Split equally';
      } else {
        final payer = payerName ?? 'Partner';
        subtitleText = '$groupName • Paid by $payer';
        isOwedExpense = true;
      }
    }

    final newExpense = Expense(
      title: title,
      subtitle: subtitleText,
      amount: amountText,
      isOwed: isOwedExpense,
      isPersonal: isPersonal,
      category: category.toLowerCase(),
      date: 'Today, Just Now',
    );

    state = [newExpense, ...state];
  }
}

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});
