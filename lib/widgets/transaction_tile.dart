import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM', 'id_ID').format(date);
  }

  bool get _isIn => transaction.transactionType == 'in';

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id ?? transaction.hashCode.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFFFFE5E5),
        child: const Icon(Icons.delete_outline, color: Color(0xFFD9531C)),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus transaksi?'),
            content: const Text('Data ini akan dihapus permanen.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isIn ? const Color(0xFFE6F1FB) : const Color(0xFFFDEEE6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: _isIn ? const Color(0xFF1A5FC8) : const Color(0xFFA03A10),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.category,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    transaction.note != null && transaction.note!.isNotEmpty
                        ? '${_formatDate(transaction.transactionDate)} · ${transaction.note}'
                        : _formatDate(transaction.transactionDate),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Text(
              '${_isIn ? '+' : '-'} ${_formatRupiah(transaction.amount)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isIn ? const Color(0xFF1A5FC8) : const Color(0xFFA03A10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
