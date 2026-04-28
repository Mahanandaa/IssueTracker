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

  final Color primary = const Color(0xFF2563EB);
  final Color bg = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    if (_uid.isEmpty) return;
    try {
      final response =
          await supabase.from('issues').select().eq('reported_by', _uid);
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
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Laporan'),
        content: const Text('Yakin ingin menghapus?'),
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
      var query =
          supabase.from('issues').select().eq('reported_by', _uid);

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

  Color _getCardColor(String? status) {
    switch (status) {
      case 'Resolved':
        return Colors.green[700]!;
      case 'Rejected':
        return Colors.red[700]!;
      case 'In Progress':
        return primary;
      case 'Pending':
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  bool _isDarkCard(String? status) {
    switch (status) {
      case 'Resolved':
      case 'Rejected':
      case 'In Progress':
        return true;
      case 'Pending':
        return false;
      default:
        return false;
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
    if (raw == null || status == 'Resolved' || status == 'Rejected') return false;
    try {
      return DateTime.parse(raw.toString()).toLocal().isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  Widget _filterBtn(String label, String? value) {
    final isActive = selectedStatus == value;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() => selectedStatus = value);

          if (value == null) {
            fetchIssues();
          } else {
            fetchByStatus(value);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.black87,
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
      backgroundColor: bg,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah", style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahLaporan()),
          );
          fetchIssues();
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications,
                            color: Colors.grey.shade700),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const NotifikasiKaryawan()),
                          );
                        },
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.person, color: Colors.grey.shade700),
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

            // SEARCH + DATE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: searchBar,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Cari laporan...',
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
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.grey.shade200),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.date_range, color: primary),
                      onPressed: _pickDate,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // FILTER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _filterBtn('All', null),
                  const SizedBox(width: 6),
                  _filterBtn('Pending', 'Pending'),
                  const SizedBox(width: 6),
                  _filterBtn('In Progress', 'In Progress'),
                  const SizedBox(width: 6),
                  _filterBtn('Escalated', 'Escalated'),
                  const SizedBox(width: 6),
                  _filterBtn('Resolved', 'Resolved'),
                  const SizedBox(width: 6),
                  _filterBtn('Rejected', 'Rejected'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LIST
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: issues.length,
                      itemBuilder: (context, index) {
                        final issue = issues[index];
                        final status = issue['status'];
                        final isResolved = status == 'Resolved';
                        final isRejected = status == 'Rejected';
                        final isPending = status == 'Pending';
                        final deadline = issue['deadline'];
                        final isOverdue = _isOverdue(deadline, status);
                        
                        final cardColor = _getCardColor(status);
                        final useWhiteText = _isDarkCard(status);
                        final textColor = useWhiteText ? Colors.white : Colors.black87;
                        final subtitleColor = useWhiteText ? Colors.white70 : Colors.grey.shade600;

                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailLaporanKaryawan(
                                    issueId: issue['id'].toString()),
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
                                // ROW TITLE & STATUS BADGE
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        issue['title'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    if (isResolved)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.check_circle,
                                                color: Colors.white, size: 12),
                                            SizedBox(width: 4),
                                            Text(
                                              'Selesai',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (isRejected)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Ditolak',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: useWhiteText
                                              ? Colors.white.withOpacity(0.25)
                                              : _statusColor(status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          status ?? '',
                                          style: TextStyle(
                                            color: useWhiteText
                                                ? Colors.white
                                                : _statusColor(status),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                
                                const SizedBox(height: 6),
                                
                                // LOKASI
                                Text(
                                  issue['location'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtitleColor,
                                  ),
                                ),
                                
                                const SizedBox(height: 6),
                                
                                // DEADLINE
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: isOverdue && !isResolved && !isRejected
                                          ? (useWhiteText ? Colors.yellow : Colors.red)
                                          : subtitleColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Deadline: ${_formatDeadline(deadline)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isOverdue && !isResolved && !isRejected
                                            ? (useWhiteText ? Colors.yellow : Colors.red)
                                            : subtitleColor,
                                        fontWeight: isOverdue && !isResolved && !isRejected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (isOverdue && !isResolved && !isRejected) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '(Terlambat)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: useWhiteText ? Colors.yellow : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                                
                                const SizedBox(height: 6),
                                
                                // ROW TANGGAL & ACTION BUTTONS
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Tanggal
                                    Text(
                                      issue['created_at'] != null 
                                          ? issue['created_at'].toString().substring(0, 10) 
                                          : '', 
                                      style: TextStyle(
                                        fontSize: 12, 
                                        color: subtitleColor,
                                      ),
                                    ),
                                    // Action Buttons atau Lihat Detail
                                    if (isPending)
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => EditLaporan(issue: issue),
                                                ),
                                              );
                                              fetchIssues();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(Icons.edit, color: Colors.orange, size: 18),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          InkWell(
                                            onTap: () => confirmDelete(issue['id']),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(Icons.delete, color: Colors.red, size: 18),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        children: [
                                          Text(
                                            "Lihat Detail",
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.arrow_forward, color: textColor, size: 14),
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
            )
          ],
        ),
      ),
    );
  }
}