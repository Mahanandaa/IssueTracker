import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LupaPassword extends StatefulWidget {
  const LupaPassword({super.key});

  @override
  State<LupaPassword> createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _ob1 = true;
  bool _ob2 = true;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  void snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> kirimOtp() async {
    if (_email.text.isEmpty) {
      snack('Email wajib');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await supabase.auth.signInWithOtp(email: _email.text.trim());
      setState(() => _isOtpSent = true);
      snack('OTP dikirim');
    } catch (e) {
      snack('Gagal kirim OTP');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> verifikasiDanGanti() async {
    if (_otp.text.isEmpty ||
        _newPass.text.isEmpty ||
        _confirmPass.text.isEmpty) {
      snack('Lengkapi semua field');
      return;
    }

    if (_newPass.text != _confirmPass.text) {
      snack('Password tidak sama');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await supabase.auth.verifyOTP(
        type: OtpType.email,
        email: _email.text.trim(),
        token: _otp.text.trim(),
      );

      if (res.session == null) {
        snack('OTP salah');
        setState(() => _isLoading = false);
        return;
      }

      await supabase.auth.updateUser(
        UserAttributes(password: _newPass.text.trim()),
      );

      snack('Password berhasil diubah');
      Navigator.pop(context);
    } catch (e) {
      snack('Gagal proses');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(22),
            width: 362,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Reset Password OTP',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_isOtpSent)
                  SizedBox(
                    width: 220,
                    height: 44,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : kirimOtp,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text(
                              'Kirim OTP',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                if (_isOtpSent) ...[
                  TextField(
                    controller: _otp,
                    decoration: InputDecoration(
                      hintText: 'OTP',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPass,
                    obscureText: _ob1,
                    decoration: InputDecoration(
                      hintText: 'Password Baru',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(_ob1
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() => _ob1 = !_ob1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPass,
                    obscureText: _ob2,
                    decoration: InputDecoration(
                      hintText: 'Konfirmasi Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(_ob2
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() => _ob2 = !_ob2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 220,
                    height: 44,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : verifikasiDanGanti,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}