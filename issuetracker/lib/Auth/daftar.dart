import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/auth_service.dart';

// Rename class ke kapital sesuai konvensi Dart
class Daftar extends StatefulWidget {
  const Daftar({super.key});

  @override
  State<Daftar> createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaController = TextEditingController();
  final _nomorController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  final authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _namaController.dispose();
    _nomorController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final nama = _namaController.text.trim();
    final nomor = _nomorController.text.trim();
    final confirm = _confirmController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        nama.isEmpty ||
        nomor.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak sama')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authService.signUp(email, password, nomor, nama);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pendaftaran berhasil! Silakan login.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal daftar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'IssueTrack.',
                style: TextStyle(
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(20),
                width: 354,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    const BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 24,
                      offset: Offset(0, 11),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Belum punya akun?',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    Text(
                      'Daftar Dulu',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Nama Lengkap'),
                    const SizedBox(height: 6),
                    _buildTextField(_namaController, 'Masukkan nama'),
                    const SizedBox(height: 14),
                    _buildLabel('Email'),
                    const SizedBox(height: 6),
                    _buildTextField(_emailController, 'nama@gmail.com',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _buildLabel('Nomor Telepon'),
                    const SizedBox(height: 6),
                    _buildTextField(_nomorController, '08xxxxxxxxxx',
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 14),
                    _buildLabel('Password'),
                    const SizedBox(height: 6),
                    _buildTextField(_passwordController, '********',
                        obscure: true),
                    const SizedBox(height: 14),
                    _buildLabel('Konfirmasi Password'),
                    const SizedBox(height: 6),
                    _buildTextField(_confirmController, '********',
                        obscure: true),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: 211,
                      height: 45,
                      child: TextButton(
                        onPressed: _isLoading ? null : signUp,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Daftar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.all(12),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}