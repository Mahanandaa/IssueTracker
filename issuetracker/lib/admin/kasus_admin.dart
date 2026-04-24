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

  final Color primary = const Color(0xFF2563EB);
  final Color bg = const Color(0xFFF8FAFC);

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

  String _formatDeadline(dynamic raw) {
    if (raw == null) return 'Tidak ada deadline';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.toString();
    }
  }

  bool _isOverdue(dynamic raw, String? status) {

    if (status == 'Resolved' || status == 'Rejected') return false;
    if (raw == null) return false;
    
    try {
      final deadline = DateTime.parse(raw.toString()).toLocal();
      final now = DateTime.now();
      return deadline.isBefore(now);
    } catch (_) {
      return false;
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'In Progress':
        return primary;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _priorityBtn(String label, String val, Color color) {
    final isSelected = selectedStatus == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedStatus = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
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
      backgroundColor: bg,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: primary,
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
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "Kasus",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: search,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Cari kasus...',
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
            ),

            const SizedBox(height: 16),

            // FILTER PRIORITY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
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
            ),

            const SizedBox(height: 16),

            // LIST KASUS
            Expanded(
              child: _isLoading
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
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredIssues.length,
                          itemBuilder: (context, index) {
                            final issue = filteredIssues[index];
                            final status = issue['status']?.toString();
                            final isResolved = status == 'Resolved';
                            final isRejected = status == 'Rejected';
                            final deadline = issue['deadline'];
                            
                            final isOverdue = _isOverdue(deadline, status);

                            Color cardColor;
                            if (isResolved) {
                              cardColor = Colors.green[700]!;
                            } else if (isRejected) {
                              cardColor = Colors.red[700]!;
                            } else {
                              switch (issue['priority']) {
                                case 'Urgent':
                                  cardColor = const Color.fromARGB(255, 243, 77, 65);
                                  break;
                                case 'High':
                                  cardColor = Colors.deepOrange;
                                  break;
                                case 'Medium':
                                  cardColor = Colors.orange;
                                  break;
                                case 'Low':
                                  cardColor = Colors.green;
                                  break;
                                default:
                                  cardColor = Colors.grey[600]!;
                              }
                            }

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
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            issue['title'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isResolved)
                                                const Icon(Icons.check_circle, 
                                                  color: Colors.white, 
                                                  size: 12,
                                                ),
                                              if (isResolved)
                                                const SizedBox(width: 4),
                                              Text(
                                                isResolved ? 'Selesai' : (status ?? '-'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (!isResolved && !isRejected) ...[
                                      Text(
                                        "Prioritas: ${issue['priority'] ?? ''}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                    Text(
                                      "Lokasi : ${issue['location'] ?? ''}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: isOverdue 
                                              ? Colors.white70 
                                            
                                                  : Colors.white70,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Deadline: ${_formatDeadline(deadline)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOverdue 
                                                ? Colors.white70
                                                
                                                    : Colors.white70,
                                            fontWeight: (isOverdue) 
                                                ? FontWeight.bold 
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        if (isOverdue) ...[
                                          const SizedBox(width: 4),
                                          const Text(
                                            '(TERLAMBAT!)',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Color.fromARGB(255, 255, 255, 255),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          issue['created_at'] != null
                                              ? 'Dibuat: ${issue['created_at'].toString().substring(0, 10)}'
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const Row(
                                          children: [
                                            Text(
                                              "Lihat Detail",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(Icons.arrow_forward,
                                                color: Colors.white, size: 14),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}