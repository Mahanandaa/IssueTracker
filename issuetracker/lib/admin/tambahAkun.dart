import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Tambahakun extends StatefulWidget {
  const Tambahakun({super.key});

  @override
  State<Tambahakun> createState() => _TambahakunState();
}

class _TambahakunState extends State<Tambahakun> {
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _adminPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureAdminPassword = true;

  final authService = AuthService();
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _teleponCtrl.dispose();
    _passwordCtrl.dispose();
    _departmentCtrl.dispose();
    _adminPasswordCtrl.dispose();
    super.dispose();
  }

  String get _adminEmail =>
      supabase.auth.currentUser?.email ?? '';

  Future<void> _simpan() async {
    final nama = _namaCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final telepon = _teleponCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final department = _departmentCtrl.text.trim();
    final adminPassword = _adminPasswordCtrl.text.trim();

    if (nama.isEmpty ||email.isEmpty ||telepon.isEmpty ||password.isEmpty ||adminPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Semua field wajib diisi (termasuk password admin)')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password teknisi minimal 6 karakter')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await authService.tambahTeknisiDanKembali(
      email: email,
      password: password,
      nama: nama,
      telepon: telepon,
      department: department.isEmpty ? null : department,
      adminEmail: _adminEmail,
      adminPassword: adminPassword,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Akun teknisi berhasil dibuat! Teknisi bisa langsung login.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat akun: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text('Tambah Akun Teknisi'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                   
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel('Nama Lengkap *'),
              const SizedBox(height: 6),
              _buildField(_namaCtrl, 'Masukkan nama teknisi'),

              const SizedBox(height: 14),

              _buildLabel('Email *'),
              const SizedBox(height: 6),
              _buildField(_emailCtrl, 'email@contoh.com',
                  keyboardType: TextInputType.emailAddress),

              const SizedBox(height: 14),

              _buildLabel('Nomor Telepon *'),
              const SizedBox(height: 6),
              _buildField(_teleponCtrl, '08xxxxxxxxxx',
                  keyboardType: TextInputType.phone),

              const SizedBox(height: 14),

              _buildLabel('Departemen (Opsional)'),
              const SizedBox(height: 6),
              _buildField(_departmentCtrl, 'Contoh: IT, Electrical'),

              const SizedBox(height: 14),

              _buildLabel('Password Teknisi *'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Min. 6 karakter',
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _simpan,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Buat Akun Teknisi',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
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
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14));
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.all(12),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}