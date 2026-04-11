import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:issuetracker/teknisi/setting_profile_teknisi.dart';
import 'package:issuetracker/teknisi/statistic_teknisi.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryTeknisi extends StatefulWidget {
  const HistoryTeknisi({super.key});

  @override
  State<HistoryTeknisi> createState() => _HistoryTeknisiState();
}

class _HistoryTeknisiState extends State<HistoryTeknisi> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> issues = [];
  bool _isLoading = false;

  DateTime theFocusDay = DateTime.now();
  DateTime theSelectedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    filterByDate(theSelectedDay);
  }

  Future<void> filterByDate(DateTime date) async {
    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      // FIX 1: Typo 'ceated_end' → 'resolved_at'
      // FIX: Filter hanya issues milik teknisi yang login
      final response = await supabase
          .from('issues')
          .select()
          .eq('assigned_to', userId)
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String());

      setState(() {
        issues = List<Map<String, dynamic>>.from(response);
      });
    } catch (a) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('ERROR: $a')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const int currentIndex = 1;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SettingProfileTeknisi()));
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("History"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020),
              focusedDay: theFocusDay,
              lastDay: DateTime.utc(theFocusDay.year + 50),
              selectedDayPredicate: (day) =>
                  DateUtils.isSameDay(theSelectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  theSelectedDay = selectedDay;
                  theFocusDay = focusedDay;
                });
                filterByDate(selectedDay);
              },
              calendarFormat: calendarFormat,
              onFormatChanged: (format) =>
                  setState(() => calendarFormat = format),
              startingDayOfWeek: StartingDayOfWeek.monday,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          'List Laporan',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        if (issues.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Text('Tidak ada laporan pada tanggal ini',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        ...issues.map((issue) {
                          // Tentukan warna status
                          Color statusColor;
                          switch (issue['status']) {
                            case 'Resolved':
                              statusColor = Colors.green[800]!;
                              break;
                            case 'In Progress':
                              statusColor = Colors.blue;
                              break;
                            case 'Rejected':
                              statusColor = Colors.red;
                              break;
                            default:
                              statusColor = Colors.grey;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        issue['title'] ?? 'Not Found',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: statusColor,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        issue['status'] ?? 'Unknown',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Ambil rating dari tabel ratings via join jika ada
                                FutureBuilder(
                                  future: supabase
                                      .from('ratings')
                                      .select('rating, feedback')
                                      .eq('issue_id', issue['id'])
                                      .maybeSingle(),
                                  builder: (context, snapshot) {
                                    final ratingData = snapshot.data
                                        as Map<String, dynamic>?;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Rating: ${ratingData?['rating'] ?? '-'}'),
                                        const Text('FeedBack:'),
                                        Text(
                                          ratingData?['feedback'] ?? '-',
                                          style: const TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}