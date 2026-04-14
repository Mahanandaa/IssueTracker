import 'package:flutter/material.dart';
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
  late TextEditingController password;

  @override
  void initState() {
    super.initState();

    nama = TextEditingController(
      text: widget.users['name']?.toString() ?? '',
    );

    email = TextEditingController(
      text: widget.users['email']?.toString() ?? '',
    );

    password = TextEditingController();
  }

  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.auth.updateUser(
      UserAttributes(
        email: email.text,
        password: password.text.isEmpty ? null : password.text,
        data: {
          'name': nama.text,
        },
      ),
    );

    await supabase.from('users').update({
      'name': nama.text,
      'email': email.text,
    }).eq('id', user.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile berhasil diupdate ✓')),
      );
      Navigator.pop(context);
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