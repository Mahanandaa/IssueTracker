import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/login.dart';
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
      snack('Email wajib diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Gunakan signInWithOtp agar {{ .Token }} muncul di email template Magic Link
      await supabase.auth.signInWithOtp(
        email: _email.text.trim(),
        shouldCreateUser: false, // jangan buat user baru jika tidak terdaftar
      );
      setState(() => _isOtpSent = true);
      snack('Kode OTP dikirim ke email');
    } catch (e) {
      snack('Gagal kirim OTP: $e');
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
      // Verifikasi OTP dengan type magiclink (sesuai signInWithOtp)
      final res = await supabase.auth.verifyOTP(
        type: OtpType.magiclink,
        email: _email.text.trim(),
        token: _otp.text.trim(),
      );

      if (res.session == null) {
        snack('OTP salah atau sudah expired');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Update password setelah sesi aktif
      await supabase.auth.updateUser(
        UserAttributes(password: _newPass.text.trim()),
      );

      // Sign out agar user login ulang dengan password baru
      await supabase.auth.signOut();

      snack('Password berhasil diubah, silakan login kembali');

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Loginpage()),
          (route) => false,
        );
      }
    } catch (e) {
      snack('Gagal proses: $e');
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
                  'Reset Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isOtpSent,
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
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Kode OTP dari email',
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
                        icon: Icon(
                            _ob1 ? Icons.visibility_off : Icons.visibility),
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
                        icon: Icon(
                            _ob2 ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _ob2 = !_ob2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() {
                              _isOtpSent = false;
                              _otp.clear();
                            }),
                    child: Text(
                      'Kirim ulang OTP',
                      style: TextStyle(color: Colors.blue[400], fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
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