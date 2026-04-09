import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Tambahakun extends StatefulWidget {
  const Tambahakun({super.key});

  @override
  State<Tambahakun> createState() => _TambahakunState();
}

class _TambahakunState extends State<Tambahakun> {
  final TextEditingController nama = TextEditingController();
  final TextEditingController nomor = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController email = TextEditingController();
  final supabase = Supabase.instance.client;

  bool isLoading = false;

  Future<void> addAcc() async {
    setState(() => isLoading = true);
    try {
      await supabase.from('users').insert({
        'name': nama.text.trim(),
        'role': 'teknisi',
        'phone': nomor.text.trim(),
        'password_hash': password.text.trim(), 
        'email': email.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun teknisi berhasil ditambahkan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah akun: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _inputField(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      backgroundColor: Colors.grey.shade200,
      title: const Text('Tambah Akun'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nama Teknisi',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(nama, 'Masukan Nama Teknisi'),
            const SizedBox(height: 20),
            const Text('Email Teknisi',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(email, 'Masukan Email Teknisi',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            const Text('Nomor Teknisi',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(nomor, 'Masukan Nomor Teknisi',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            const Text('Password',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(password, 'Masukan Password', isPassword: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        if (nama.text.isEmpty ||
                            email.text.isEmpty ||
                            nomor.text.isEmpty ||
                            password.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Semua field wajib diisi!')),
                          );
                        } else {
                          addAcc();
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Simpan Akun',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}