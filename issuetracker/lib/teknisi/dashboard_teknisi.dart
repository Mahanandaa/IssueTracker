import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/detail_laporan_teknisi.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';
import 'package:issuetracker/teknisi/setting_profile_teknisi.dart';
import 'package:issuetracker/teknisi/statistic_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardTeknisi extends StatefulWidget {
  const DashboardTeknisi({super.key});

  @override
  State<DashboardTeknisi> createState() => _DashboardTeknisiState();
}

class _DashboardTeknisiState extends State<DashboardTeknisi> {
  int _currentIndex = 0;

  final supabase = Supabase.instance.client;
  final SearchBar = TextEditingController();
  String? selectedStatus = "All";

  List<Map<String, dynamic>> issues = [];
  bool _isLoading = false;

  String get _uid => supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }
Future<void> fetchIssues() async {
    if (_uid.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('issues')
          .select()
          .eq('assigned_to', _uid)
          .order('assigned_at', ascending: false);

      if (mounted) {
        setState(() {
          issues = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('fetchIssues teknisi error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Cari issue berdasarkan judul atau lokasi
  Future<void> fenchData([String? searchTerm]) async {
    if (_uid.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      var response = await supabase
          .from('issues')
          .select()
          .eq('assigned_to', _uid)
          .or('title.ilike.%$searchTerm%,location.ilike.%$searchTerm%')
          .order('assigned_at', ascending: false);

      if (mounted) {
        setState(() {
          issues = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.message}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredIssues =
        selectedStatus == null || selectedStatus == 'All'
            ? issues
            : issues.where((e) => e['priority'] == selectedStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),

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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DashboardTeknisi()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HistoryTeknisi()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Statistic()));
          } else if (index == 3) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingProfileTeknisi()));
          }
        },
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selamat Datang.",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 14),

                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xffe6e6e6),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: TextField(
                    controller: SearchBar,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Cari Tugas...",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        fetchIssues();
                      } else {
                        fenchData(value);
                      }
                    },
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedStatus = 'All'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedStatus == 'All'
                            ? Colors.blue
                            : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(child: Text("All")),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedStatus = 'Low'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedStatus == 'Low'
                                ? Colors.green
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(child: Text("Rendah")),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedStatus = 'Medium'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedStatus == 'Medium'
                                ? Colors.orange
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(child: Text("Menengah")),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedStatus = 'High'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedStatus == 'High'
                                ? Colors.deepOrange
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(child: Text("Tinggi")),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedStatus = 'Urgent'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedStatus == 'Urgent'
                                ? Colors.red
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(child: Text("Darurat")),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  "Tugas Terbaru",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredIssues.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak Ada Laporan',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredIssues.length,
                            itemBuilder: (context, index) {
                              final issue = filteredIssues[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailLaporanTeknisi(
                                        issueId: issue['id'].toString(),
                                      ),
                                    ),
                                  );
                                },

                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),

                                  decoration: BoxDecoration(
                                    color: issue['priority'] == 'Urgent'
                                        ? const Color.fromARGB(255, 243, 77, 65)
                                        : Colors.grey[700],
                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            issue['title'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),

                                          Text(
                                            issue['priority'] ?? '',
                                            style: TextStyle(
                                              color: issue['priority'] == 'Urgent'
                                                  ? Colors.white
                                                  : issue['priority'] == 'Medium'
                                                      ? Colors.orange
                                                      : Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                         "Lokasi : ${issue['location'] ?? 'Location Not Found'}",
                                          style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            issue['created_at'] != null
                                                ? issue['created_at']
                                                    .toString()
                                                    .substring(0, 10)
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                            ),
                                          ),

                                          const Text(
                                            "Lihat Detail",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}