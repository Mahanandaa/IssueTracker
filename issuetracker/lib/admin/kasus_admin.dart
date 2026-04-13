import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:issuetracker/admin/data_admin.dart';
import 'package:issuetracker/admin/detail_laporan_admin.dart';
import 'package:issuetracker/admin/profile_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KasusAdmin extends StatefulWidget {
  const KasusAdmin({super.key});

  @override
  State<KasusAdmin> createState() => _KasusAdminState();
}

class _KasusAdminState extends State<KasusAdmin> {
  final supabase = Supabase.instance.client;
  int _currentIndex = 1;
  List<Map<String, dynamic>> issues = [];
  final search = TextEditingController();
  bool _isLoading = false;
  String? selectedStatus = "All";

  int getPriorityOrder(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 1;
      case 'high':
        return 2;
      case 'medium':
        return 3;
      case 'low':
        return 4;
      default:
        return 5;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('issues').select();
      setState(() {
        issues = List<Map<String, dynamic>>.from(response);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fenchData([String? searchTerm]) async {
    setState(() => _isLoading = true);
    try {
      var query = supabase.from('issues').select();
      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = supabase
            .from('issues')
            .select()
            .or('title.ilike.%$searchTerm%,location.ilike.%$searchTerm%');
      }
      final data = await query;
      setState(() {
        issues = List<Map<String, dynamic>>.from(data);
      });
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error : ${error.message}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // FIX 2: Warna background card berdasarkan status
  Color _cardColor(Map<String, dynamic> issue) {
    final status = issue['status']?.toString();
    if (status == 'Resolved') return Colors.green[100]!;
    if (status == 'Rejected') return Colors.red[50]!;
    if (issue['priority'] == 'Urgent') return const Color.fromARGB(255, 243, 77, 65);
    return Colors.grey[100]!;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredIssues = issues.where((issue) {
      if (selectedStatus == "All") return true;
      return issue['priority'] == selectedStatus;
    }).toList();

    filteredIssues.sort((a, b) => getPriorityOrder(a['priority'] ?? '')
        .compareTo(getPriorityOrder(b['priority'] ?? '')));

    return Scaffold(
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
              icon: Icon(Icons.work), label: 'Kasus'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storage_rounded), label: 'Data'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DashboardAdmin()));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const KasusAdmin()));
          } else if (index == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DataAdmin()));
          } else if (index == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ProfileAdmin()));
          }
        },
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("Kasus"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Search
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xffe6e6e6),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: search,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Cari Kasus...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: fenchData,
                ),
              ),

              const SizedBox(height: 10),

              // Filter priority
              Row(
                children: [
                  _priorityBtn('All', 'All', Colors.blue),
                  const SizedBox(width: 6),
                  _priorityBtn('Rendah', 'Low', Colors.green),
                  const SizedBox(width: 6),
                  _priorityBtn('Menengah', 'Medium', Colors.orange),
                  const SizedBox(width: 6),
                  _priorityBtn('Tinggi', 'High', Colors.deepOrange),
                  const SizedBox(width: 6),
                  _priorityBtn('Darurat', 'Urgent', Colors.red),
                ],
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
                                color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredIssues.length,
                          itemBuilder: (context, index) {
                            final issue = filteredIssues[index];
                            final status = issue['status']?.toString();

                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailLaporanAdmin(
                                      issueId: issue['id'].toString(),
                                    ),
                                  ),
                                );
                                fetchIssues();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  // FIX 2: warna hijau untuk Resolved
                                  color: _cardColor(issue),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            issue['title'] ?? '',
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        // FIX 2: badge status
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                          decoration: BoxDecoration(
                                            color: status == 'Resolved'
                                                ? Colors.green[700]
                                                : status == 'Rejected'
                                                    ? Colors.red[700]
                                                    : Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            status ?? '-',
                                            style: TextStyle(
                                              color: (status ==
                                                              'Resolved' ||
                                                          status ==
                                                              'Rejected')
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      issue['priority'] ?? '',
                                      style: TextStyle(
                                        color: {
                                              'Urgent': Colors.red,
                                              'High': Colors.deepOrange,
                                              'Medium': Colors.orange.shade800,
                                              'Low': Colors.green,
                                            }[issue['priority']
                                                ?.toString()] ??
                                            Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        "Lokasi : ${issue['location'] ?? ''}"),
                                    const SizedBox(height: 4),
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
                                        ),
                                        const Text(
                                          "Lihat Detail",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
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
    );
  }

  Widget _priorityBtn(String label, String val, Color color) {
    final isSelected = selectedStatus == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedStatus = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}