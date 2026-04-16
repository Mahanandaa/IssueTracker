import 'package:flutter/material.dart';
import 'package:issuetracker/karyawan/detail_laporan_karyawan.dart';
import 'package:issuetracker/karyawan/edit_laporan.dart';
import 'package:issuetracker/karyawan/notifikasi_karyawan.dart';
import 'package:issuetracker/karyawan/setting_profile.dart';
import 'package:issuetracker/karyawan/tambah_laporan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardKaryawan extends StatefulWidget {
  const DashboardKaryawan({super.key});

  @override
  State<DashboardKaryawan> createState() => _DashboardKaryawanState();
}

class _DashboardKaryawanState extends State<DashboardKaryawan> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> issues = [];

  String get _uid => supabase.auth.currentUser?.id ?? '';

  final searchBar = TextEditingController();
  DateTime? selectedDate;
  bool _isLoading = false;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    if (_uid.isEmpty) return;
    try {
      final response = await supabase
          .from('issues')
          .select()
          .eq('reported_by', _uid);
      if (mounted) {
        setState(() {
          issues = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('fetchIssues error: $e');
    }
  }

  Future<void> deleteIssues(dynamic id) async {
    try {
      await supabase.from('issues').delete().eq('id', id.toString());
      fetchIssues();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> confirmDelete(dynamic id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan Masalah'),
        content:
            const Text('Yakin ingin menghapus laporan masalah ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) deleteIssues(id);
  }

  Future<void> filterByDate(DateTime date) async {
    setState(() => _isLoading = true);
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      final response = await supabase
          .from('issues')
          .select()
          .eq('reported_by', _uid)
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String());
      setState(() {
        issues = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchByStatus(String status) async {
    final response = await supabase
        .from('issues')
        .select()
        .eq('reported_by', _uid)
        .eq('status', status);
    setState(() {
      issues = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> fenchData([String? searchTerm]) async {
    setState(() => _isLoading = true);
    try {
      var query = supabase.from('issues').select().eq('reported_by', _uid);
      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = supabase
            .from('issues')
            .select()
            .eq('reported_by', _uid)
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      await filterByDate(picked);
    }
  }

  Color _cardColor(String? status) {
    switch (status) {
      case 'Resolved':
        return Colors.green[100]!;
      case 'Rejected':
        return Colors.red[100]!;
      case 'In Progress':
        return Colors.blue[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Resolved':
        return Colors.green[800]!;
      case 'Rejected':
        return Colors.red[800]!;
      case 'In Progress':
        return Colors.blue[800]!;
      case 'Pending':
        return Colors.orange[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  Color _statusBgColor(String? status) {
    switch (status) {
      case 'Resolved':
        return Colors.green[200]!;
      case 'Rejected':
        return Colors.red[200]!;
      case 'In Progress':
        return Colors.blue[100]!;
      case 'Pending':
        return Colors.orange[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Widget _filterBtn(String label, String? statusVal, Color activeColor) {
    final isActive = selectedStatus == statusVal;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => selectedStatus = statusVal);
          if (statusVal == 'All' || statusVal == null) {
            fetchIssues();
          } else {
            fetchByStatus(statusVal);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahLaporan()),
          );
          fetchIssues();
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selamat datang.',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 26),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const NotifikasiKaryawan()),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.person, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ProfileSettingKaryawan()),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Search bar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: searchBar,
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
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.date_range_outlined,
                      color: Colors.blue[400], size: 28),
                  onPressed: _pickDate,
                ),
              ],
            ),

            if (selectedDate != null)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Tanggal: ${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                      style:
                          const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => selectedDate = null);
                        fetchIssues();
                      },
                      child: const Text("Reset Filter"),
                    )
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Filter status buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _filterBtn('All', 'All', Colors.blue[700]!),
                  const SizedBox(width: 4),
                  _filterBtn('Pending', 'Pending', Colors.orange[700]!),
                  const SizedBox(width: 4),
                  _filterBtn('Progress', 'In Progress', Colors.blue[700]!),
                  const SizedBox(width: 4),
                  _filterBtn('Resolved', 'Resolved', Colors.green[700]!),
                  const SizedBox(width: 4),
                  _filterBtn('Rejected', 'Rejected', Colors.red[700]!),
                  const SizedBox(width: 4),
                  _filterBtn('Escalated', 'Escalated', Colors.orange[900]!),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Issue list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : issues.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada laporan",
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                                color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          itemCount: issues.length,
                          itemBuilder: (context, index) {
                            final issue = issues[index];
                            final status =
                                issue['status']?.toString();

                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetailLaporanKaryawan(
                                            issueId: issue['id']
                                                .toString()),
                                  ),
                                );
                                fetchIssues();
                              },
                              // FIX 2: Warna background berdasarkan status
                              child: Container(
                                margin: const EdgeInsets.only(
                                    bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _cardColor(status),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            issue['title'] ??
                                                'Title Not Found',
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 4,
                                                  horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    5),
                                          ),
                                          child: Text(
                                            issue['priority'] ?? '',
                                            style: TextStyle(
                                              color: issue['priority'] ==
                                                          'Urgent' ||
                                                      issue['priority'] ==
                                                          'High'
                                                  ? Colors.red
                                                  : issue['priority'] ==
                                                          'Medium'
                                                      ? Colors.orange
                                                      : Colors.green,
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                        'Lokasi : ${issue['location'] ?? '-'}'),
                                    Text(
                                      issue['created_at'] != null
                                          ? issue['created_at']
                                              .toString()
                                              .substring(0, 10)
                                          : '',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        // Tombol delete & edit hanya untuk Pending
                                        if (status == 'Pending' ||
                                            status == null) ...[
                                          ElevatedButton(
                                            onPressed: () =>
                                                confirmDelete(
                                                    issue['id']),
                                            child: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 18),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        EditLaporan(
                                                            issue:
                                                                issue)),
                                              );
                                              fetchIssues();
                                            },
                                            child: Icon(
                                                Icons.edit_document,
                                                color:
                                                    Colors.orange[900],
                                                size: 18),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        // Badge status
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 5,
                                                  horizontal: 10),
                                          decoration: BoxDecoration(
                                            color:
                                                _statusBgColor(status),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    4),
                                          ),
                                          child: Text(
                                            status ??
                                                'Status Not Found',
                                            style: TextStyle(
                                              color:
                                                  _statusColor(status),
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
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