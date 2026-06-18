import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_env.dart';
import '../auth/auth_service.dart';
import '../auth/auth_provider.dart';
import '../groups/groups_provider.dart';

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

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: json['amount'] as String,
      isOwed: json['isOwed'] as bool,
      isPersonal: json['isPersonal'] as bool,
      category: json['category'] as String,
      date: json['date'] as String,
    );
  }
}

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  final AuthService _authService;
  final Ref _ref;

  ExpensesNotifier(this._authService, this._ref) : super([]) {
    fetchExpenses();
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authService.jwtToken != null) 'Authorization': 'Bearer ${_authService.jwtToken}',
  };

  Future<void> fetchExpenses() async {
    if (_authService.jwtToken == null) return;
    try {
      final url = Uri.parse('${AppEnv.apiBaseUrl}/expenses');
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        state = data.map((e) => Expense.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String groupName,
    required String category,
    required bool isPersonal,
    required bool isPaidByMe,
    String? payerName,
    String? splitMethod,
  }) async {
    String? groupId;
    if (!isPersonal) {
      final groups = _ref.read(groupsProvider);
      // Try to find the group matching name, fallback to first group if not found
      final matchingGroups = groups.where((g) => g.name == groupName);
      if (matchingGroups.isNotEmpty) {
        groupId = matchingGroups.first.id;
      } else if (groups.isNotEmpty) {
        groupId = groups.first.id;
      }
    }

    final url = Uri.parse('${AppEnv.apiBaseUrl}/expenses');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'category': category,
        'isPersonal': isPersonal,
        'groupId': groupId,
      }),
    );

    if (response.statusCode == 201) {
      await fetchExpenses();
      // Also trigger a refresh of groups to recalculate balances
      _ref.read(groupsProvider.notifier).fetchGroups();
    } else {
      throw Exception('Failed to add expense');
    }
  }
}

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ExpensesNotifier(authService, ref);
});
