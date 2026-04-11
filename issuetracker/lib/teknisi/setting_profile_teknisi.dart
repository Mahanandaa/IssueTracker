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
  State<SettingProfileTeknisi> createState() => _SettingProfileTeknisiState();
}

class _SettingProfileTeknisiState extends State<SettingProfileTeknisi> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  // FIX 3: Variabel untuk menyimpan data rating & waktu pengerjaan dari DB
  double avgRating = 0.0;
  String avgDuration = '-';

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Ambil profil user
    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    // FIX 3a: Ambil rata-rata rating dari tabel ratings berdasarkan technician_id
    final ratingsResponse = await supabase
        .from('ratings')
        .select('rating')
        .eq('technician_id', user.id);

    double calculatedRating = 0.0;
    if (ratingsResponse.isNotEmpty) {
      final List ratings = ratingsResponse as List;
      final total = ratings.fold<int>(
          0, (sum, r) => sum + ((r['rating'] as int?) ?? 0));
      calculatedRating = total / ratings.length;
    }

    // FIX 3b: Ambil rata-rata waktu pengerjaan dari issues yang sudah resolved
    // Waktu pengerjaan = resolved_at - assigned_at (dalam menit)
    final resolvedIssues = await supabase
        .from('issues')
        .select('assigned_at, resolved_at')
        .eq('assigned_to', user.id)
        .eq('status', 'Resolved')
        .not('resolved_at', 'is', null)
        .not('assigned_at', 'is', null);

    String durationStr = '-';
    if (resolvedIssues.isNotEmpty) {
      final List issues = resolvedIssues as List;
      int totalMinutes = 0;
      int count = 0;
      for (var issue in issues) {
        try {
          final assigned = DateTime.parse(issue['assigned_at']);
          final resolved = DateTime.parse(issue['resolved_at']);
          final diff = resolved.difference(assigned).inMinutes;
          totalMinutes += diff;
          count++;
        } catch (_) {}
      }
      if (count > 0) {
        final avgMin = totalMinutes ~/ count;
        if (avgMin < 60) {
          durationStr = '$avgMin Menit';
        } else {
          final hours = avgMin ~/ 60;
          final minutes = avgMin % 60;
          durationStr = minutes > 0 ? '$hours Jam $minutes Mnt' : '$hours Jam';
        }
      }
    }

    setState(() {
      userData = response;
      avgRating = calculatedRating;
      avgDuration = durationStr;
      isLoading = false;
    });
  }

  void logout() async {
    await authService.keluar();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const Loginpage()));
  }

  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => DashboardTeknisi()));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HistoryTeknisi()));
          } else if (index == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const Statistic()));
          } else if (index == 3) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const SettingProfileTeknisi()));
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card profil
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Color.fromARGB(255, 200, 200, 200), blurRadius: 6)
              ],
            ),
            child: Column(
              children: [
                // FIX 3c: Tampilkan foto profil jika ada, fallback ke ikon
                CircleAvatar(
                  radius: 40,
                  backgroundImage: userData?['photo_url'] != null
                      ? NetworkImage(userData!['photo_url'])
                      : null,
                  child: userData?['photo_url'] == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 15),
                Text(
                  userData?['name'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 5),
                Text(userData?['email'] ?? ''),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // FIX 3: Rating & Rata-rata waktu dari database
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(height: 6),
                      const Text("Rating",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(avgRating > 0
                          ? avgRating.toStringAsFixed(1)
                          : 'Belum ada'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.timer, color: Colors.blue),
                      const SizedBox(height: 6),
                      const Text("Rata-rata",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(avgDuration),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tombol edit profil
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditProfileTeknisi(users: userData!),
                ),
              );
              // Refresh data setelah kembali dari edit profil
              setState(() => isLoading = true);
              await getUserData();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 24,
                    offset: Offset(0, 11),
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Edit Profile Akun',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Toggle tema gelap
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Color.fromARGB(255, 200, 200, 200),
                    blurRadius: 6)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tema Gelap',
                    style: TextStyle(fontWeight: FontWeight.w600)),
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

          // Tombol keluar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Color.fromARGB(255, 200, 200, 200),
                    blurRadius: 6)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Keluar',
                    style: TextStyle(fontWeight: FontWeight.w600)),
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