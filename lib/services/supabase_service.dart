import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<TransactionModel>> getTransactionsThisMonth() async {
    if (_userId == null) return [];

    final response = await _client
        .from('tbl_transaction')
        .select()
        .eq('user_id', _userId!)
        .order('transaction_date', ascending: false);

    return (response as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByFilter(String filter) async {
    if (_userId == null) return [];

    final now = DateTime.now();
    String fromDate;
    switch (filter) {
      case 'hari':
        fromDate = now.toIso8601String().split('T')[0];
        break;
      case 'minggu':
        fromDate = now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0];
        break;
      default:
        fromDate = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
    }

    final response = await _client
        .from('tbl_transaction')
        .select()
        .eq('user_id', _userId!)
        .gte('transaction_date', fromDate)
        .order('transaction_date', ascending: false);

    return (response as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    if (_userId == null) return [];

    final response = await _client
        .from('tbl_transaction')
        .select()
        .eq('user_id', _userId!)
        .gte('transaction_date', start.toIso8601String().split('T')[0])
        .lte('transaction_date', end.toIso8601String().split('T')[0])
        .order('transaction_date', ascending: true);

    return (response as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final data = tx.toJson();
    data['user_id'] = _userId;
    await _client.from('tbl_transaction').insert(data);
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from('tbl_transaction').delete().eq('id', id);
  }
}
