import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

// Warna utama app
const kPrimary = Color(0xFF3B6FF0);
const kPrimaryLight = Color(0xFFEEF2FF);
const kSurface = Color(0xFFF8F9FC);
const kBorder = Color(0xFFE2E8F0);
const kText = Color(0xFF1A202C);
const kSubtext = Color(0xFF718096);

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

  File? _newPhoto;
  String? _currentPhotoUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _obscurePass = true;

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: kBorder, borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: kPrimary),
              title: const Text('Ambil dari Kamera',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: kPrimary),
              title: const Text('Pilih dari Galeri',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
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
      return supabase.storage.from('images').getPublicUrl(path);
    } catch (e) {
      if (mounted) _showSnack('Gagal upload foto');
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
        _showSnack('Profil berhasil diperbarui ✓');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: kText),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: kText, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kSubtext, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: kSubtext, size: 20)
            : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: kSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kText),
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.w700, color: kText, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          children: [

            // — Foto profil —
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimary, width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: kPrimaryLight,
                      backgroundImage: _newPhoto != null
                          ? FileImage(_newPhoto!) as ImageProvider
                          : (_currentPhotoUrl != null
                              ? NetworkImage(_currentPhotoUrl!)
                              : null),
                      child: (_newPhoto == null && _currentPhotoUrl == null)
                          ? const Icon(Icons.person, size: 48, color: kPrimary)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_newPhoto != null) ...[
              const SizedBox(height: 10),
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF38A169), size: 14),
                    SizedBox(width: 4),
                    Text('Foto baru dipilih',
                        style: TextStyle(color: Color(0xFF38A169), fontSize: 13)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // — Form fields —
            _fieldLabel("Nama Lengkap"),
            const SizedBox(height: 8),
            _inputField(nama, "Masukan nama baru", prefixIcon: Icons.person_outline),

            const SizedBox(height: 18),
            _fieldLabel("Email"),
            const SizedBox(height: 8),
            _inputField(email, "Masukan email baru",
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined),

            const SizedBox(height: 18),
            _fieldLabel("No. HP"),
            const SizedBox(height: 8),
            _inputField(
              nomor,
              "Masukan nomor baru",
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: Icons.phone_outlined,
            ),

            const SizedBox(height: 18),
            _fieldLabel("Password Baru"),
            const SizedBox(height: 4),
            const Text("Kosongkan jika tidak ingin mengubah password",
                style: TextStyle(color: kSubtext, fontSize: 12)),
            const SizedBox(height: 8),
            _inputField(
              password,
              "Masukan password baru",
              obscure: _obscurePass,
              prefixIcon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: kSubtext, size: 20,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : updateProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        "Simpan Perubahan",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}