import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:issuetracker/Auth/login.dart';
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

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        data = response;
      });
    }
  }

  void logout() async {
    await authService.keluar();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Loginpage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile Admin"),
        backgroundColor: Colors.grey[200],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: data == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data?['name'] ?? 'Not Found',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data?['role'] ?? 'Not Found',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 20, 121, 236),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(data?['email'] ?? 'Not Found'),
                    Text(data?['phone'] ?? 'Not Found'),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileAdmin(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 153, 160, 167),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Edit Profile akun',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 153, 160, 167),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tema Gelap',
                            style: TextStyle(fontWeight: FontWeight.w600),
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
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 153, 160, 167),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Keluar',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            onPressed: logout,
                            icon: const Icon(Icons.exit_to_app),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}