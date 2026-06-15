import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
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
  DateTime? _startDate;
  DateTime? _endDate;
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
      List<TransactionModel> data;
      if (_filter == 'custom' && _startDate != null && _endDate != null) {
        data = await _service.getTransactionsByDateRange(_startDate!, _endDate!);
      } else {
        data = await _service.getTransactionsByFilter(_filter);
      }
      setState(() { _transactions = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _filter = 'custom';
      });
      _load();
    }
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  Widget _buildChart() {
    // Group by day
    Map<String, Map<String, double>> dailyData = {};
    for (var t in _transactions) {
      String dateStr = DateFormat('dd/MM').format(t.transactionDate);
      if (!dailyData.containsKey(dateStr)) {
        dailyData[dateStr] = {'in': 0, 'out': 0};
      }
      dailyData[dateStr]![t.transactionType] = (dailyData[dateStr]![t.transactionType] ?? 0) + t.amount;
    }

    List<String> dates = dailyData.keys.toList().reversed.toList(); // Oldest to newest
    if (dates.length > 10) {
      dates = dates.sublist(dates.length - 10); // Show max 10 days for readability
    }

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < dates.length; i++) {
      String date = dates[i];
      double inAmount = dailyData[date]!['in'] ?? 0;
      double outAmount = dailyData[date]!['out'] ?? 0;
      
      if (inAmount > maxY) maxY = inAmount;
      if (outAmount > maxY) maxY = outAmount;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: inAmount,
              color: const Color(0xFF1A5FC8),
              width: 10,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: outAmount,
              color: const Color(0xFFD9531C),
              width: 10,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY == 0 ? 100 : maxY * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < dates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(dates[value.toInt()], style: const TextStyle(fontSize: 10)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
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
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _filter == 'custom' ? const Color(0xFFE6F1FB) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _filter == 'custom' ? const Color(0xFF378ADD) : Colors.grey.shade300,
                          width: 0.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.date_range, 
                        size: 16, 
                        color: _filter == 'custom' ? const Color(0xFF0C447C) : Colors.grey
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_filter == 'custom' && _startDate != null && _endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                ),
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0F4FA),
                            borderRadius: BorderRadius.only(
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
            
            const SizedBox(height: 24),
            
            // Chart Section
            if (!_isLoading && _transactions.isNotEmpty) ...[
              const Text('Grafik Pemasukan & Pengeluaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                height: 250,
                padding: const EdgeInsets.only(top: 24, right: 16, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200, width: 0.5),
                ),
                child: _buildChart(),
              ),
              const SizedBox(height: 24),
            ],
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
