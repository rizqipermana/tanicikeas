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
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
        ),
        child: Row(
          children: [
            // Icon bulat
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _isIn ? const Color(0xFFE6F1FB) : const Color(0xFFFDEEE6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: _isIn ? const Color(0xFF1A5FC8) : const Color(0xFFA03A10),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Info transaksi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isIn ? const Color(0xFFE6F1FB) : const Color(0xFFFDEEE6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _isIn ? 'Pemasukan' : 'Pengeluaran',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _isIn ? const Color(0xFF1A5FC8) : const Color(0xFFA03A10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(transaction.transactionDate),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        transaction.note!,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            // Nominal
            Text(
              '${_isIn ? '+' : '-'} ${_formatRupiah(transaction.amount)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _isIn ? const Color(0xFF1A5FC8) : const Color(0xFFA03A10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
