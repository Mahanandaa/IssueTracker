import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:issuetracker/Auth/login.dart';
import 'package:issuetracker/admin/edit_data_akun.dart';
import 'package:issuetracker/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileAdmin extends StatefulWidget {
  const ProfileAdmin({super.key});

  @override
  State<ProfileAdmin> createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<ProfileAdmin> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? data;
  bool isLoading = true;

  File? _newPhoto;
  bool _isUploadingPhoto = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            data = response ?? {};
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          data = {};
          isLoading = false;
        });
      }
    }
  }

  Future<void> _changePhoto() async {
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

    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _newPhoto = File(picked.path);
      _isUploadingPhoto = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final path = 'avatars/avatar_$userId.jpg';

      await supabase.storage.from('images').upload(
            path,
            _newPhoto!,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl =
          supabase.storage.from('images').getPublicUrl(path);

      await supabase
          .from('users')
          .update({'photo_url': publicUrl}).eq('id', userId);

      await fetchUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui ✓')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void logout() async {
    await authService.keluar();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Loginpage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final shadowColor =
        isDark ? Colors.black45 : const Color.fromARGB(255, 200, 200, 200);

    final photoUrl = data?['photo_url'];

    final ImageProvider? avatarImage = _newPhoto != null
        ? FileImage(_newPhoto!)
        : (photoUrl is String && photoUrl.isNotEmpty
            ? NetworkImage(photoUrl)
            : null);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingPhoto ? null : _changePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: _isUploadingPhoto
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  data?['name'] ?? '',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor),
                ),
                const SizedBox(height: 5),
                Text(
                  data?['email'] ?? '',
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 5),
                Text(
                  data?['phone'] ?? '',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditDataAkun(users: data ?? {}),
                ),
              );
              await fetchUser();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 24,
                    offset: const Offset(0, 11),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Edit Profile Akun',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: textColor),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tema Gelap',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: textColor),
                ),
                ValueListenableBuilder(
                  valueListenable: themeNotifier,
                  builder: (context, ThemeMode mode, _) {
                    return Switch(
                      value: mode == ThemeMode.dark,
                      onChanged: (val) {
                        themeNotifier.value =
                            val ? ThemeMode.dark : ThemeMode.light;
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Keluar',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: textColor),
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app_outlined,
                      color: Colors.red),
                  onPressed: logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}