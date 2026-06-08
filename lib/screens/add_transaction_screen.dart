import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../services/supabase_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final String type; // 'in' atau 'out'

  const AddTransactionScreen({super.key, required this.type});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _service = SupabaseService();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _catsIn = ['Penjualan Singkong', 'Penjualan Lain'];
  final List<String> _catsOut = ['Bibit', 'Pupuk', 'Pestisida', 'Upah', 'Transportasi', 'Lainnya'];

  List<String> get _categories => widget.type == 'in' ? _catsIn : _catsOut;

  bool get _isIn => widget.type == 'in';
  Color get _primaryColor => _isIn ? const Color(0xFF1A5FC8) : const Color(0xFFD9531C);
  Color get _bgColor => _isIn ? const Color(0xFFE6F1FB) : const Color(0xFFFDEEE6);
  Color get _borderColor => _isIn ? const Color(0xFF378ADD) : const Color(0xFFF4924E);

  Future<void> _simpan() async {
    if (_selectedCategory == null) {
      _showSnack('Pilih kategori terlebih dahulu');
      return;
    }
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showSnack('Masukkan nominal');
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnack('Nominal tidak valid');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final tx = TransactionModel(
        transactionType: widget.type,
        category: _selectedCategory!,
        amount: amount,
        note: _noteController.text.trim(),
        transactionDate: DateTime.now(),
      );
      await _service.addTransaction(tx);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isIn ? 'Tambah Pemasukan' : 'Tambah Pengeluaran',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kategori',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3,
              children: _categories.map((cat) {
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? _bgColor : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? _borderColor : Colors.grey.shade300,
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected ? _primaryColor : Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Nominal (Rp)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Contoh: 700000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Catatan (opsional)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Simpan',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
