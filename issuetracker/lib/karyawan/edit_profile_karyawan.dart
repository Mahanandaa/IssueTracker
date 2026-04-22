import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

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

  // FIX 4: Foto profil
  File? _newPhoto;
  String? _currentPhotoUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nama = TextEditingController(text: widget.users['name']);
    email = TextEditingController(text: widget.users['email']);
    nomor = TextEditingController(text: widget.users['phone']);
    password = TextEditingController();
    _currentPhotoUrl = widget.users['photo_url'] as String?;
  }

  @override
  void dispose() {
    nama.dispose();
    email.dispose();
    nomor.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked =
        await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _newPhoto = File(picked.path));
    }
  }

  Future<String?> _uploadPhoto(String userId) async {
    if (_newPhoto == null) return _currentPhotoUrl;
    final filename = 'avatar_$userId.jpg';
    final path = 'avatars/$filename';
    try {
      await supabase.storage.from('images').upload(
            path,
            _newPhoto!,
            fileOptions: const FileOptions(upsert: true),
          );
      final publicUrl =
          supabase.storage.from('images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal upload foto')));
      }
      return _currentPhotoUrl;
    }
  }

  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final photoUrl = await _uploadPhoto(user.id);

      await supabase.auth.updateUser(UserAttributes(
        email: email.text.trim(),
        password: password.text.isEmpty ? null : password.text,
        data: {
          'name': nama.text.trim(),
          'phone': nomor.text.trim(),
        },
      ));

        await supabase.from('users').update({
        'name': nama.text.trim(),
        'email': email.text.trim(),
        'phone': nomor.text.trim(),
        'photo_url': photoUrl,
        }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui ✓')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _inputField(TextEditingController controller, String hint,
      {bool obscure = false,
      TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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

            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundImage: _newPhoto != null
                        ? FileImage(_newPhoto!) as ImageProvider
                        : (_currentPhotoUrl != null
                            ? NetworkImage(_currentPhotoUrl!)
                            : null),
                    child: (_newPhoto == null && _currentPhotoUrl == null)
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: Colors.blue, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_newPhoto != null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text('Foto baru dipilih ✓',
                      style: TextStyle(color: Colors.green, fontSize: 13)),
                ),
              ),

            const SizedBox(height: 24),

            const Text("Nama",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(nama, "Masukan nama baru"),

            const SizedBox(height: 18),
            const Text("Email",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(email, "Masukan email baru"),

            const SizedBox(height: 18),
            const Text("No HP",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(
              nomor,
              "Masukan nomor baru",
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 18),
            const Text("Password Baru",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(
                password, "Kosongkan jika tidak ganti password",
                obscure: true),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : updateProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}