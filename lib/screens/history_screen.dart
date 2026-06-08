import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onRefresh;
  const HistoryScreen({super.key, this.onRefresh});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = SupabaseService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getTransactionsThisMonth();
      setState(() { _transactions = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('Riwayat Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )),
              )
            else if (_transactions.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200, width: 0.5),
                  ),
                  child: Column(
                    children: _transactions.map((tx) =>
                      TransactionTile(
                        transaction: tx,
                        onDelete: () async {
                          if (tx.id != null) {
                            await _service.deleteTransaction(tx.id!);
                            _load();
                            widget.onRefresh?.call();
                          }
                        },
                      )
                    ).toList(),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
