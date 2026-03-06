import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:issuetracker/Auth/login.dart';
import 'package:issuetracker/main.dart';
import 'package:issuetracker/teknisi/edit_profile_teknisi.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';
import 'package:issuetracker/teknisi/statistic_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_teknisi.dart';
class SettingProfileTeknisi extends StatefulWidget {
  const SettingProfileTeknisi({super.key});

  @override
  State<SettingProfileTeknisi> createState() =>
      _SettingProfileTeknisiState();
}

class _SettingProfileTeknisiState
    extends State<SettingProfileTeknisi> {

  final authService = AuthService();
  final supabase = Supabase.instance.client;

  User? get user => supabase.auth.currentUser;

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
    int _currentIndex = 0;
    return Scaffold(
      backgroundColor: Colors.grey[100],
       bottomNavigationBar: BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.grey[200],
  selectedItemColor: Colors.blue,
  unselectedItemColor: Colors.grey,
  currentIndex: _currentIndex,
  items: const [
    BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined), label: 'Dashboard'),
    BottomNavigationBarItem(
        icon: Icon(Icons.history), label: 'History'),
    BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart), label: 'Statistic'),
    BottomNavigationBarItem(
        icon: Icon(Icons.settings), label: 'Settings'),
  ],

  onTap: (index) {

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardTeknisi(),
        ),
      );
    }

    else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HistoryTeknisi(),
        ),
      );
    }

    else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Statistic(),
        ),
      );
    }

    else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingProfileTeknisi(),
        ),
      );
    }
  },
),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          FutureBuilder(
           future: user == null ? null: supabase.from('users').select().eq('id', user!.id).single(),
           builder: (context, snapshot) {

              if (user == null) {
      return const Text("User tidak ditemukan");
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData) {
      return const Text("Data tidak ditemukan");
    }

    final data = snapshot.data as Map<String, dynamic>;

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 200, 200, 200),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Column(
                  children: [

                   

                    const SizedBox(height: 20),

                   

                    const SizedBox(height: 20),
                    
                  ],
                ),
              );
            },
          ),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(
                                      10),
                              border: Border.all(
                                  color:
                                      Colors.blue),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.amber),
                                SizedBox(height: 6),
                                Text(
                                  "Rating",
                                  style: TextStyle(
                                      fontWeight:
                                          FontWeight.w600),
                                ),
                                Text("4.8"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(
                                      10),
                              border: Border.all(
                                  color:
                                      Colors.blue),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.timer,
                                    color:
                                        Colors.blue),
                                SizedBox(height: 6),
                                Text(
                                  "Rata-rata",
                                  style: TextStyle(
                                      fontWeight:
                                          FontWeight.w600),
                                ),
                                Text("1 Jam"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
          const SizedBox(height: 20),
            GestureDetector(
        
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const EditProfileTeknisi(),
                          ),
                        );
                      },
                      child: Container(
                        
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(
                                vertical: 16),
                        decoration: BoxDecoration(
                          
                          boxShadow: [
                            
                                            BoxShadow(
                                              color: Color(0x19000000),
                                              blurRadius: 24,
                                              offset: Offset(0, 11),
                                            ),
                                          ],
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Edit Profile Akun',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color:
                      Color.fromARGB(255, 200, 200, 200),
                  blurRadius: 6,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tema Gelap',
                  style: TextStyle(
                      fontWeight: FontWeight.w600),
                ),
                ValueListenableBuilder(
                  valueListenable: themeNotifier,
                  builder:
                      (context, ThemeMode mode, _) {
                    return Switch(
                      value:
                          mode == ThemeMode.dark,
                      onChanged: (val) {
                        themeNotifier.value =
                            val
                                ? ThemeMode.dark
                                : ThemeMode.light;
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color:
                      Color.fromARGB(255, 200, 200, 200),
                  blurRadius: 6,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Keluar',
                  style: TextStyle(
                      fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.exit_to_app_outlined,
                    color: Colors.red,
                  ),
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