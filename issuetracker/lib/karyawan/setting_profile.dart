import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:issuetracker/karyawan/edit_profile_karyawan.dart';
import 'package:issuetracker/main.dart';
import 'package:issuetracker/Auth/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingKaryawan extends StatefulWidget {
  const ProfileSettingKaryawan({super.key});

  @override
  State<ProfileSettingKaryawan> createState() =>
      _ProfileSettingKaryawanState();
}

class _ProfileSettingKaryawanState extends State<ProfileSettingKaryawan> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;

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
    final user = supabase.auth.currentUser;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final shadowColor =
        isDark ? Colors.black45 : const Color.fromARGB(255, 200, 200, 200);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder(
            future:
                supabase.from('users').select().eq('id', user!.id).single(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Text("Terjadi error");
              }

              final data = snapshot.data as Map<String, dynamic>;

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: shadowColor, blurRadius: 6)
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: data['photo_url'] != null
                              ? NetworkImage(data['photo_url'])
                              : null,
                          child: data['photo_url'] == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          data['name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data['email'] ?? '',
                          style: TextStyle(color: textColor),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data['phone'] ?? '',
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
                          builder: (_) =>
                              EditProfileKaryawan(users: data),
                        ),
                      );
                      setState(() {});
                    },
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
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
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 15),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: shadowColor, blurRadius: 6)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tema Gelap',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
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
              boxShadow: [
                BoxShadow(color: shadowColor, blurRadius: 6)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Keluar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
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