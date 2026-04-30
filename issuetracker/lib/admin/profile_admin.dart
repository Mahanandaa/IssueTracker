import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:issuetracker/Auth/login.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:issuetracker/admin/data_admin.dart';
import 'package:issuetracker/admin/edit_data_akun.dart';
import 'package:issuetracker/admin/kasus_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileAdmin extends StatefulWidget {
  const ProfileAdmin({super.key});

  @override
  State<ProfileAdmin> createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<ProfileAdmin> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;
  int _currentIndex = 3;

  Map<String, dynamic>? data;
  bool isLoading = true;

  File? _newPhoto;
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

  void logout() async {
    await authService.keluar();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Loginpage()),
    );
  }

  String _formatRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'karyawan':
        return 'Karyawan';
      case 'teknisi':
        return 'Teknisi';
      default:
        return role ?? '-';
    }
  }

  Color _roleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.blue;
      case 'karyawan':
        return Colors.green;
      case 'teknisi':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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
    final role = data?['role'] as String?;

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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardAdmin(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KasusAdmin(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DataAdmin(),
              ),
            );
          } else if (index == 3) {
            // Sudah di halaman ini
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work), label: 'Kasus'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storage), label: 'Data'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
      backgroundColor: Colors.white,
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
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 12),

                // Nama
                Text(
                  data?['name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Badge Role
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: _roleColor(role).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _roleColor(role), width: 1),
                  ),
                  child: Text(
                    _formatRole(role),
                    style: TextStyle(
                      color: _roleColor(role),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      data?['email'] ?? '',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Telepon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      data?['phone'] ?? '',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tombol Edit Profile
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
                    offset: const Offset(0, 2),
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

          // Tombol Keluar
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