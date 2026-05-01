import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class Expense {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final DateTime date;
  final String category;
  final String? paymentMethod;

  Expense({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.paymentMethod,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      category: json['category'],
      paymentMethod: json['paymentMethod'],
    );
  }
}

final expenseListProvider = StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ExpenseNotifier(dio);
});

class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final Dio _dio;

  ExpenseNotifier(this._dio) : super(const AsyncValue.loading()) {
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/api/expenses');
      final List<dynamic> data = response.data['data'];
      final expenses = data.map((e) => Expense.fromJson(e)).toList();
      state = AsyncValue.data(expenses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    try {
      await _dio.post('/api/expenses', data: expenseData);
      fetchExpenses();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _dio.delete('/api/expenses/$id');
      fetchExpenses();
    } catch (e) {
      rethrow;
    }
  }
}
