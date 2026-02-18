import 'package:flutter/material.dart';
import 'auth_service.dart';

class daftar extends StatefulWidget {
  daftar({super.key});

  @override
  State<daftar> createState() => _daftarState();
}

class _daftarState extends State<daftar> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaController = TextEditingController();
  final _nomorController = TextEditingController();
  final _confirmController = TextEditingController();

  final authService = AuthService();

  void signUp(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final nama = _namaController.text.trim();
    final nomor = _nomorController.text.trim();
    final confirm = _confirmController.text.trim();

    if (email.isEmpty || password.isEmpty ||nama.isEmpty || nomor.isEmpty ||confirm.isEmpty) {
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

    try {
      await authService.daftar(email, password, nomor, nama);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("ERROR : $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
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
            SizedBox(height: 50),
            Container(
              padding: EdgeInsets.all(20),
              height: 710,
              width: 354,
              decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 24,
                    offset: Offset(0, 11),
                  ),
                ],
              ),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                    Text(
                    'Belum punya akun?',
                     style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  Text(
                    'Daftar Dulu',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Nama Lengkap',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 6),
                  TextField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama',
                      contentPadding: EdgeInsets.all(12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'nama@gmail.com',
                      contentPadding: EdgeInsets.all(12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Nomor Telepon',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 6),
                  TextField(
                    controller: _nomorController,
                    decoration: InputDecoration(
                      hintText: '08xxxxxxxxxx',
                      contentPadding: EdgeInsets.all(12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '********',
                      contentPadding: EdgeInsets.all(12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Konfirmasi Password',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 6),
                  TextField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '********',
                      contentPadding: EdgeInsets.all(12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 22),
                  SizedBox(
                    width: 211,
                    height: 45,
                    child: TextButton(
                      onPressed: () => signUp(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Daftar',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
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
