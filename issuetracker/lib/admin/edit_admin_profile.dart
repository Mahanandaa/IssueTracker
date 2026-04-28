import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAdminProfile extends StatefulWidget {
  final Map<String, dynamic> users;

  const EditAdminProfile({super.key, required this.users});

  @override
  State<EditAdminProfile> createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {
  final supabase = Supabase.instance.client;

  late TextEditingController nama;
  late TextEditingController email;
  late TextEditingController nomor;
  late TextEditingController password;

  static const _supabaseUrl    = 'https://ivzuhuebueotbjpfunxp.supabase.co';
  static const _serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2enVodWVidWVvdGJqcGZ1bnhwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTM1ODM1MCwiZXhwIjoyMDg2OTM0MzUwfQ.mWZvQjMTEkjzDTuUrEko8zoXR4gQVno80yronMxqV4s';

  Future<void> _adminUpdateEmail(String userId, String newEmail) async {
    final uri = Uri.parse('$_supabaseUrl/auth/v1/admin/users/$userId');
    final res = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'apikey': _serviceRoleKey,
        'Authorization': 'Bearer $_serviceRoleKey',
      },
      body: jsonEncode({'email': newEmail, 'email_confirm': true}),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['msg'] ?? body['message'] ?? 'Gagal update email');
    }
  }

  @override
  void initState() {
    super.initState();

    nama = TextEditingController(
      text: widget.users['name']?.toString() ?? '',
    );

    email = TextEditingController(
      text: widget.users['email']?.toString() ?? '',
    );

    nomor = TextEditingController(
      text: widget.users['phone']?.toString() ?? '',
    );

    password = TextEditingController();
  }

  @override
  void dispose() {
    nama.dispose();
    email.dispose();
    nomor.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final newEmail = email.text.trim();
      final emailChanged = newEmail != (user.email ?? '');
      final passwordChanged = password.text.isNotEmpty;

      if (emailChanged) {
        await _adminUpdateEmail(user.id, newEmail);
      }

      if (passwordChanged) {
        await supabase.auth.updateUser(UserAttributes(password: password.text));
      }

      await supabase.from('users').update({
        'name': nama.text.trim(),
        'email': newEmail,
        'phone': nomor.text.trim(),
        if (passwordChanged) 'password_hash': password.text,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile berhasil diupdate ✓')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile Admin"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: nama,
              decoration: inputStyle("Masukan nama baru"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: email,
              decoration: inputStyle("Masukan email baru"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nomor,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: inputStyle("Masukan nomor telepon baru"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              decoration: inputStyle("Masukan password baru"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateProfile,
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}