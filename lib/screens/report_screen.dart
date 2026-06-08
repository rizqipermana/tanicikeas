import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../models/transaction.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _service = SupabaseService();
  String _filter = 'bulan';
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  double get _totalIn => _transactions
      .where((t) => t.transactionType == 'in')
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalOut => _transactions
      .where((t) => t.transactionType == 'out')
      .fold(0, (sum, t) => sum + t.amount);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getTransactionsByFilter(_filter);
      setState(() { _transactions = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16, top: 4),
              child: Text('Laporan Keuangan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),

            // Filter buttons
            Row(
              children: [
                _FilterBtn(label: 'Hari Ini', value: 'hari', selected: _filter,
                  onTap: () { setState(() => _filter = 'hari'); _load(); }),
                const SizedBox(width: 8),
                _FilterBtn(label: 'Minggu Ini', value: 'minggu', selected: _filter,
                  onTap: () { setState(() => _filter = 'minggu'); _load(); }),
                const SizedBox(width: 8),
                _FilterBtn(label: 'Bulan Ini', value: 'bulan', selected: _filter,
                  onTap: () { setState(() => _filter = 'bulan'); _load(); }),
              ],
            ),
            const SizedBox(height: 16),

            // Laporan card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200, width: 0.5),
              ),
              child: _isLoading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ))
                  : Column(
                      children: [
                        _LaporanRow(
                          icon: Icons.trending_up,
                          iconColor: const Color(0xFF1A5FC8),
                          label: 'Pemasukan',
                          value: _formatRupiah(_totalIn),
                          valueColor: const Color(0xFF1A5FC8),
                        ),
                        const Divider(height: 0.5, thickness: 0.5),
                        _LaporanRow(
                          icon: Icons.trending_down,
                          iconColor: const Color(0xFFD9531C),
                          label: 'Pengeluaran',
                          value: _formatRupiah(_totalOut),
                          valueColor: const Color(0xFFD9531C),
                        ),
                        const Divider(height: 0.5, thickness: 0.5),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FA),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                          ),
                          child: _LaporanRow(
                            icon: Icons.monetization_on_outlined,
                            iconColor: const Color(0xFF0D7A5F),
                            label: 'Laba',
                            value: _formatRupiah(_totalIn - _totalOut),
                            valueColor: const Color(0xFF0D7A5F),
                            isBold: true,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label, value, selected;
  final VoidCallback onTap;
  const _FilterBtn({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE6F1FB) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? const Color(0xFF378ADD) : Colors.grey.shade300,
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? const Color(0xFF0C447C) : Colors.grey,
            )),
        ),
      ),
    );
  }
}

class _LaporanRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, valueColor;
  final String label, value;
  final bool isBold;
  const _LaporanRow({required this.icon, required this.iconColor, required this.label, required this.value, required this.valueColor, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isBold ? Colors.black87 : Colors.grey.shade700,
          )),
          const Spacer(),
          Text(value, style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor,
          )),
        ],
      ),
    );
  }
}
