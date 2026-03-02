import  'package:flutter/material.dart';
import 'package:issuetracker/karyawan/setting_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileKaryawan extends StatefulWidget {
  final Map users;

  const EditProfileKaryawan({super.key, required this.users});

  @override
  State<EditProfileKaryawan> createState() => _EditProfileKaryawanState();
}

class _EditProfileKaryawanState extends State<EditProfileKaryawan> {

  final supabase = Supabase.instance.client;

  late TextEditingController nama;
  late TextEditingController email;
  late TextEditingController nomor;
  late TextEditingController password;

  @override
  void initState(){
    super.initState();
    nama = TextEditingController(text: widget.users['name']);
    email = TextEditingController(text: widget.users['email']);
    nomor = TextEditingController(text: widget.users['phone']);
    password = TextEditingController();
  }

  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if(user == null) return;

    await supabase.auth.updateUser(
      UserAttributes(
        email: email.text,
        password: password.text.isEmpty ? null : password.text,
        data: {
          'name': nama.text,
          'phone': nomor.text,
        }
      )
    );

    await supabase.from('users').update({
          'name': nama.text,
          'email': email.text,
          'phone': nomor.text,
        }).eq('id', user.id);

   
  }

  Widget _inputField(TextEditingController controller, String hint){
    return TextField(
      controller: controller,
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
        backgroundColor: Colors.grey[200],
        title: const Text("Edit Profile"),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [

            const SizedBox(height: 12),

            const CircleAvatar(
              radius: 42,
              child: Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 24),

            const Text("Nama", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(nama, "Masukan nama baru"),

            const SizedBox(height: 18),

            const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(email, "Masukan email baru"),

            const SizedBox(height: 18),

            const Text("No HP", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(nomor, "Masukan nomor baru"),

            const SizedBox(height: 18),

            const Text("Password Baru", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(password, "Kosongkan jika tidak ganti password"),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: updateProfile,
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}