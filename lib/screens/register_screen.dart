import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnack('Semua kolom harus diisi');
      return;
    }
    if (password.length < 6) {
      _showSnack('Password minimal 6 karakter');
      return;
    }
    if (password != confirm) {
      _showSnack('Password dan konfirmasi tidak sama');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      // Simpan ke tbl_user
      if (response.user != null) {
        await Supabase.instance.client.from('tbl_user').insert({
          'id': response.user!.id,
          'full_name': name,
          'phone_number': '',
        });
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Pendaftaran Berhasil! 🎉'),
            content: const Text(
              'Akun kamu sudah dibuat. Silakan cek email untuk verifikasi, lalu login.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5FC8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('OK, Ke Halaman Login',
                  style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.contains('already registered')) msg = 'Email sudah terdaftar';
      if (msg.contains('invalid')) msg = 'Format email tidak valid';
      _showSnack(msg);
    } catch (e) {
      _showSnack('Terjadi kesalahan, coba lagi');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3B7A),
      body: SafeArea(
        child: Column(
          children: [
            // Header kecil
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Icon(Icons.grass_rounded, color: Color(0xFF90B8EE), size: 22),
                  const SizedBox(width: 6),
                  const Text('TaniCikeas',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Form card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Buat Akun',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      const Text('Daftar untuk mulai mencatat keuangan',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 24),

                      _buildLabel('Nama Lengkap'),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: _nameController,
                        hint: 'Contoh: Pak Sugiono',
                        icon: Icons.person_outline,
                        type: TextInputType.name,
                      ),
                      const SizedBox(height: 14),

                      _buildLabel('Email'),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: _emailController,
                        hint: 'contoh@email.com',
                        icon: Icons.email_outlined,
                        type: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),

                      _buildLabel('Password'),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: _passwordController,
                        hint: 'Minimal 6 karakter',
                        icon: Icons.lock_outline,
                        obscure: _obscurePassword,
                        toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                        showToggle: true,
                        isObscured: _obscurePassword,
                      ),
                      const SizedBox(height: 14),

                      _buildLabel('Konfirmasi Password'),
                      const SizedBox(height: 8),
                      _buildInput(
                        controller: _confirmController,
                        hint: 'Ulangi password',
                        icon: Icons.lock_outline,
                        obscure: _obscureConfirm,
                        toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        showToggle: true,
                        isObscured: _obscureConfirm,
                      ),
                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A5FC8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : const Text('Daftar Sekarang',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun? ',
                            style: TextStyle(color: Colors.grey, fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text('Masuk',
                              style: TextStyle(
                                color: Color(0xFF1A5FC8),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87));

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? type,
    bool obscure = false,
    bool showToggle = false,
    bool isObscured = false,
    VoidCallback? toggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: toggleObscure,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A5FC8), width: 1.5),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
