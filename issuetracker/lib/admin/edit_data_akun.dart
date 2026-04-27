import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/Auth/auth_gate.dart';

class EditDataAkun extends StatefulWidget {
  final Map users;
  const EditDataAkun({super.key, required this.users});

  @override
  State<EditDataAkun> createState() => _EditDataAkunState();
}

class _EditDataAkunState extends State<EditDataAkun> {
  final supabase = Supabase.instance.client;

  late TextEditingController nama;
  late TextEditingController email;
  late TextEditingController nomor;
  late TextEditingController password;

  File? _newPhoto;
  String? _currentPhotoUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    nama = TextEditingController(text: widget.users['name'] ?? '');
    email = TextEditingController(text: widget.users['email'] ?? '');
    nomor = TextEditingController(text: widget.users['phone'] ?? '');
    password = TextEditingController();

    _currentPhotoUrl = widget.users['photo_url'];
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
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

    final path = 'avatars/avatar_$userId.jpg';

    await supabase.storage.from('images').upload(
          path,
          _newPhoto!,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('images').getPublicUrl(path);
  }

  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final photoUrl = await _uploadPhoto(user.id);
      final newEmail = email.text.trim();
      final emailChanged = newEmail != user.email;
      final passwordChanged = password.text.isNotEmpty;

      // FIX #5: Bangun UserAttributes secara kondisional
      Map<String, dynamic> userData = {
        'name': nama.text,
        'phone': nomor.text,
      };

      UserAttributes authAttributes;

      if (emailChanged && passwordChanged) {
        authAttributes = UserAttributes(
          email: newEmail,
          password: password.text,
          data: userData,
        );
      } else if (emailChanged) {
        authAttributes = UserAttributes(
          email: newEmail,
          data: userData,
        );
      } else if (passwordChanged) {
        authAttributes = UserAttributes(
          password: password.text,
          data: userData,
        );
      } else {
        authAttributes = UserAttributes(
          data: userData,
        );
      }

      // Update di Supabase Auth
      await supabase.auth.updateUser(authAttributes);

      // Update tabel users
      final updateData = {
        'name': nama.text,
        'email': newEmail,
        'phone': nomor.text,
        if (photoUrl != null) 'photo_url': photoUrl,
      };
      
      await supabase.from('users').update(updateData).eq('id', user.id);

      // **PERBAIKAN UTAMA: Jika email berubah, logout dan minta login ulang**
      if (emailChanged) {
        // Sign out untuk clear session lama
        await supabase.auth.signOut();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email berhasil diubah! Silakan login kembali dengan email baru.'),
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate ke login page dan clear semua history
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
          );
        }
      } else if (passwordChanged) {
        // Jika hanya ganti password, tetap perlu login ulang
        await supabase.auth.signOut();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password berhasil diubah! Silakan login kembali.'),
              duration: Duration(seconds: 2),
            ),
          );
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
          );
        }
      } else {
        // Update profile biasa (nama, nomor, foto)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile berhasil diupdate ✓')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        // Handle error email sudah digunakan
        if (errorMsg.contains('already been registered') || 
            errorMsg.contains('already exists')) {
          errorMsg = 'Email sudah digunakan oleh akun lain!';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMsg')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget inputField(TextEditingController controller, String hint,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? image = _newPhoto != null
        ? FileImage(_newPhoto!)
        : (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty
            ? NetworkImage(_currentPhotoUrl!)
            : null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Data Akun"),
        backgroundColor: Colors.grey[200],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 10),

            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: image,
                    child: image == null
                        ? const Icon(Icons.person, size: 40)
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
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            label('Nama'),
            inputField(nama, 'Masukan Nama'),

            label('Email'),
            inputField(email, 'Masukan Email'),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Perubahan email akan mengharuskan login ulang',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ),

            label('Nomor Telepon'),
            inputField(nomor, 'Nomor Telepon'),

            label('Password (kosongkan jika tidak ingin mengubah)'),
            inputField(password, 'Password baru', obscure: true),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : updateProfile,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}