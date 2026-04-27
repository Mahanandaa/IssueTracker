import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:issuetracker/Auth/login.dart';
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

    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    final ratingsResponse = await supabase
        .from('ratings')
        .select('rating')
        .eq('technician_id', user.id);

    final resolvedCount = await supabase
        .from('issues')
        .select('id')
        .eq('assigned_to', user.id)
        .eq('status', 'Resolved');
    final int jumlahSelesai = (resolvedCount as List).length;

    double calculatedRating = 0.0;
    if (ratingsResponse != null && (ratingsResponse as List).isNotEmpty && jumlahSelesai > 0) {
      final List ratings = ratingsResponse;
      double total = 0;
      for (var r in ratings) {
        final val = r['rating'];
        if (val != null) total += (val as num).toDouble();
      }
      calculatedRating = total / jumlahSelesai;
    }

    final resolvedIssues = await supabase
        .from('issues')
        .select('assigned_at, resolved_at')
        .eq('assigned_to', user.id)
        .eq('status', 'Resolved')
        .not('resolved_at', 'is', null)
        .not('assigned_at', 'is', null);

    String durationStr = '-';
    if (resolvedIssues != null && (resolvedIssues as List).isNotEmpty) {
      int totalMinutes = 0;
      int count = 0;
      for (var issue in resolvedIssues) {
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
          final hours = avgMin / 60;
          final minutes = avgMin % 60;
          durationStr =
              minutes > 0 ? '$hours Jam $minutes Mnt' : '$hours Jam';
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

  // FIX #2: helper untuk label role
  String _getRoleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'teknisi':
        return 'Teknisi';
      case 'karyawan':
        return 'Karyawan';
      default:
        return role ?? '-';
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'teknisi':
        return Colors.blue;
      case 'karyawan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final borderColor = Colors.blue;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final shadowColor = isDark
        ? Colors.black45
        : const Color.fromARGB(255, 200, 200, 200);

    // FIX #2: ambil role dari userData
    final role = userData?['role'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
                MaterialPageRoute(builder: (_) => const DashboardTeknisi()));
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
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: shadowColor, blurRadius: 6)],
            ),
            child: Column(
              children: [
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor),
                ),
                const SizedBox(height: 5),
                Text(userData?['email'] ?? '',
                    style: TextStyle(color: textColor)),
                const SizedBox(height: 10),

                // FIX #2: tampilkan badge role
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getRoleColor(role)),
                  ),
                  child: Text(
                    _getRoleLabel(role),
                    style: TextStyle(
                      color: _getRoleColor(role),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(height: 6),
                      Text("Rating",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: textColor)),
                      Text(
                        avgRating > 0
                            ? '${avgRating.toStringAsFixed(1)} / 5'
                            : 'Belum ada',
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.timer, color: Colors.blue),
                      const SizedBox(height: 6),
                      Text("Rata-rata",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: textColor)),
                      Text(avgDuration,
                          style: TextStyle(color: textColor)),
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
                  builder: (_) => EditProfileTeknisi(users: userData!),
                ),
              );
              setState(() => isLoading = true);
              await getUserData();
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
                    offset: const Offset(0, 5),
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
                Text('Keluar',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: textColor)),
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