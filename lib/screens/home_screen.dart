import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import '../services/supabase_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = SupabaseService();
  int _currentIndex = 0;

  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  double get _totalIn => _transactions
      .where((t) => t.transactionType == 'in')
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalOut => _transactions
      .where((t) => t.transactionType == 'out')
      .fold(0, (sum, t) => sum + t.amount);

  double get _saldo => _totalIn - _totalOut;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadData();
  // }

  // Future<void> _loadData() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final data = await _service.getTransactionsThisMonth();
  //     setState(() {
  //       _transactions = data;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() => _isLoading = false);
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Gagal memuat data: $e')),
  //       );
  //     }
  //   }
  // }

  @override
void initState() {
  super.initState();
  Future.delayed(const Duration(milliseconds: 500), () {
    _loadData();
  });
}

Future<void> _loadData() async {
  setState(() => _isLoading = true);
  try {
    final data = await _service.getTransactionsThisMonth();
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }
}

  String _formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      HistoryScreen(onRefresh: _loadData),
      ReportScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) _loadData();
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE6F1FB),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF1A5FC8)),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list, color: Color(0xFF1A5FC8)),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF1A5FC8)),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                color: const Color(0xFF0D3B7A),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat datang,',
                      style: TextStyle(color: Color(0xFF90B8EE), fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TaniCikeas 🌾',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text('Keluar?'),
                                content: const Text('Kamu akan keluar dari akun ini.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                  TextButton(onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Keluar', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await Supabase.instance.client.auth.signOut();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.logout, color: Colors.white, size: 14),
                                SizedBox(width: 5),
                                Text('Keluar', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Kartu Saldo
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A5FC8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2A72DC), width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saldo Saat Ini',
                            style: TextStyle(color: Color(0xFFB5D4F7), fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          _isLoading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : Text(
                                  _formatRupiah(_saldo),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: SummaryCard(
                                  label: 'Pemasukan',
                                  value: _formatRupiah(_totalIn),
                                  valueColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SummaryCard(
                                  label: 'Pengeluaran',
                                  value: _formatRupiah(_totalOut),
                                  valueColor: const Color(0xFFFFB085),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SummaryCard(
                                  label: 'Laba',
                                  value: _formatRupiah(_saldo),
                                  valueColor: const Color(0xFFA3F0C0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Tombol Tambah Transaksi
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: '+ Pemasukan',
                        color: const Color(0xFF1A5FC8),
                        bgColor: const Color(0xFFE6F1FB),
                        borderColor: const Color(0xFF378ADD),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddTransactionScreen(type: 'in'),
                            ),
                          );
                          _loadData();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: '- Pengeluaran',
                        color: const Color(0xFFA03A10),
                        bgColor: const Color(0xFFFDEEE6),
                        borderColor: const Color(0xFFF4924E),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddTransactionScreen(type: 'out'),
                            ),
                          );
                          _loadData();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Transaksi Terakhir
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'TRANSAKSI TERAKHIR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Text(
    'DEBUG: jumlah transaksi = ${_transactions.length}',
    style: const TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    ),
  ),
),
              
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
              else if (_transactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Belum ada transaksi bulan ini',
                      style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200, width: 0.5),
                  ),
                  child: Column(
                    children: _transactions.take(5).map((tx) =>
                      TransactionTile(
                        transaction: tx,
                        onDelete: () async {
                          if (tx.id != null) {
                            await _service.deleteTransaction(tx.id!);
                            _loadData();
                          }
                        },
                      )
                    ).toList(),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color, bgColor, borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
