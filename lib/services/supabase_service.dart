import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // ID user yang sedang login
  String? get _userId => _client.auth.currentUser?.id;

  // Ambil semua transaksi bulan ini (milik user yg login)
  // Future<List<TransactionModel>> getTransactionsThisMonth() async {
  //   final now = DateTime.now();
  //   final firstDay = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
  //   final lastDay = DateTime(now.year, now.month + 1, 0).toIso8601String().split('T')[0];

  //   final response = await _client
  //       .from('tbl_transaction')
  //       .select()
  //       .eq('user_id', _userId ?? '')
  //       .gte('transaction_date', firstDay)
  //       .lte('transaction_date', lastDay)
  //       .order('transaction_date', ascending: false);

  //   return (response as List).map((e) => TransactionModel.fromJson(e)).toList();
  // }

  
// Future<List<TransactionModel>> getTransactionsThisMonth() async {
//    print('USER ID = $_userId');
//   if (_userId == null) {
//      print('USER BELUM LOGIN');
//     return [];
//   }

//   final now = DateTime.now();
//   final firstDay =
//       DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
//   final lastDay =
//       DateTime(now.year, now.month + 1, 0).toIso8601String().split('T')[0];

//    print('FIRST DAY = $firstDay');
//   print('LAST DAY = $lastDay');

//   final response = await _client
//       .from('tbl_transaction')
//       .select()
//       .eq('user_id', _userId!)
//       .gte('transaction_date', firstDay)
//       .lte('transaction_date', lastDay)
//       .order('transaction_date', ascending: false);
  
//  print('THIS MONTH RESPONSE = $response');
//   return (response as List)
//       .map((e) => TransactionModel.fromJson(e))
//       .toList();
// }

  Future<List<TransactionModel>> getTransactionsThisMonth() async {
  if (_userId == null) return [];
  
  final response = await _client
      .from('tbl_transaction')
      .select()
      .order('transaction_date', ascending: false);

  return (response as List).map((e) => TransactionModel.fromJson(e)).toList();
}

  // Ambil transaksi berdasarkan filter
  // Future<List<TransactionModel>> getTransactionsByFilter(String filter) async {
  //   final now = DateTime.now();
  //   String fromDate;

  //   switch (filter) {
  //     case 'hari':
  //       fromDate = now.toIso8601String().split('T')[0];
  //       break;
  //     case 'minggu':
  //       fromDate = now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0];
  //       break;
  //     case 'bulan':
  //     default:
  //       fromDate = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
  //   }

  //   final response = await _client
  //       .from('tbl_transaction')
  //       .select()
  //       .eq('user_id', _userId ?? '')
  //       .gte('transaction_date', fromDate)
  //       .order('transaction_date', ascending: false);

  //   return (response as List).map((e) => TransactionModel.fromJson(e)).toList();
  // }
  Future<List<TransactionModel>> getTransactionsByFilter(String filter) async {
  if (_userId == null) {
    return [];
  }

  final now = DateTime.now();
  String fromDate;

  switch (filter) {
    case 'hari':
      fromDate = now.toIso8601String().split('T')[0];
      break;
    case 'minggu':
      fromDate =
          now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0];
      break;
    default:
      fromDate =
          DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
  }

  final response = await _client
      .from('tbl_transaction')
      .select()
      .eq('user_id', _userId!)
      .gte('transaction_date', fromDate)
      .order('transaction_date', ascending: false);

  return (response as List)
      .map((e) => TransactionModel.fromJson(e))
      .toList();
}

  // Tambah transaksi baru (otomatis pakai user_id yang login)
  Future<void> addTransaction(TransactionModel tx) async {
    final data = tx.toJson();
    data['user_id'] = _userId;
    await _client.from('tbl_transaction').insert(data);
  }

  // Hapus transaksi
  Future<void> deleteTransaction(String id) async {
    await _client.from('tbl_transaction').delete().eq('id', id);
  }
}
