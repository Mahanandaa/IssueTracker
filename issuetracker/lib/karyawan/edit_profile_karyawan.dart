import 'package:flutter/material.dart';
import 'package:issuetracker/karyawan/setting_profile.dart';
class EditProfileKaryawan extends StatefulWidget {
  const EditProfileKaryawan({super.key});

  @override
  State<EditProfileKaryawan> createState() => _EditProfileKaryawanState();
}

class _EditProfileKaryawanState extends State<EditProfileKaryawan> {
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

            const Text(
              "Nama",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Masukkan nama",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Email",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Masukkan email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "No HP",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Masukkan nomor HP",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Password Baru",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Masukkan password baru",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 28),
  SizedBox(
  width: double.infinity,
  child: TextButton(
    style: TextButton.styleFrom(
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      shadowColor: Colors.black26,
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => profilesettingkaryawan(),
        ),
      );
    },
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
