import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:issuetracker/Auth/login.dart';

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

  Future<void> signUp() async {
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
          const SnackBar(content: Text('Pendaftaran berhasil! Silakan login.')),
        );

        // Langsung pindah ke halaman login tanpa delay
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Loginpage()),
        );
      }
    } catch (e) {
      if (mounted) {
        // Tampilkan pesan error yang lebih bersih (tanpa prefix "Exception:")
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal daftar: $msg')));
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
                ),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(20),
                width: 354,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Daftar Akun',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Nama Lengkap'),
                    _buildTextField(_namaController, 'Masukkan nama'),

                    const SizedBox(height: 14),
                    _buildLabel('Email'),
                    _buildTextField(_emailController, 'nama@gmail.com'),

                    const SizedBox(height: 14),
                    _buildLabel('Nomor Telepon'),
                    _buildTextField(_nomorController, '08xxxxxxxxxx'),

                    const SizedBox(height: 14),
                    _buildLabel('Password'),
                    _buildTextField(_passwordController, '********',
                        obscure: true),

                    const SizedBox(height: 14),
                    _buildLabel('Konfirmasi Password'),
                    _buildTextField(_confirmController, '********',
                        obscure: true),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: TextButton(
                        onPressed: _isLoading ? null : signUp,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Daftar',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      child: Text(
                        'Sudah Punya Akun? Login',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade600),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const Loginpage()));
                      },
                    )
                  ],
                ),
              ),
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}