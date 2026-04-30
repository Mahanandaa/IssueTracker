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

  // Filter by STATUS (bukan priority)
  String? _selectedStatus; // null = All

  final Color primary = const Color(0xFF2563EB);
  final Color bg = const Color(0xFFF8FAFC);

  // Urutan prioritas untuk sorting
  int getPriorityOrder(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent': return 1;
      case 'high':   return 2;
      case 'medium': return 3;
      case 'low':    return 4;
      default:       return 5;
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
      return DateTime.parse(raw.toString()).toLocal().isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  // ── STATUS badge helpers ──────────────────────────────────────────────────

  /// Warna latar badge status
  Color _statusBadgeBg(String? status) {
    switch (status) {
      case 'Resolved':   return Colors.green;
      case 'Rejected':   return Colors.red.shade600;
      case 'In Progress':return primary;
      case 'Pending':    return Colors.orange;
      case 'Assigned':   return Colors.purple;
      default:           return Colors.grey;
    }
  }

  /// Label status dalam Bahasa Indonesia
  String _statusLabel(String? status) {
    switch (status) {
      case 'Resolved':    return 'Selesai';
      case 'Rejected':    return 'Ditolak';
      case 'In Progress': return 'Dikerjakan';
      case 'Pending':     return 'Menunggu';
      case 'Assigned':    return 'Ditugaskan';
      default:            return status ?? '-';
    }
  }

  /// Icon status
  IconData _statusIcon(String? status) {
    switch (status) {
      case 'Resolved':    return Icons.check_circle;
      case 'Rejected':    return Icons.cancel;
      case 'In Progress': return Icons.build_circle;
      case 'Pending':     return Icons.hourglass_top;
      case 'Assigned':    return Icons.assignment_ind;
      default:            return Icons.info_outline;
    }
  }

  // ── PRIORITY badge helpers ────────────────────────────────────────────────

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'Urgent': return Colors.red;
      case 'High':   return Colors.orange.shade700;
      case 'Medium': return Colors.orange;
      case 'Low':    return Colors.orange.shade300;
      default:       return Colors.grey;
    }
  }

  String _priorityLabel(String? priority) {
    switch (priority) {
      case 'Urgent': return 'Darurat';
      case 'High':   return 'Tinggi';
      case 'Medium': return 'Menengah';
      case 'Low':    return 'Rendah';
      default:       return priority ?? '-';
    }
  }

  // ── Filter bottom sheet (by Status) ──────────────────────────────────────

  void _showFilterSheet() {
    final statuses = [
      null,              // All
      'Pending',
      'Assigned',
      'In Progress',
      'Resolved',
      'Rejected',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Filter by Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: statuses.map((s) {
                    final isAll = s == null;
                    final label = isAll ? 'Semua' : _statusLabel(s);
                    final isSelected = _selectedStatus == s;
                    final color = isAll ? Colors.blue : _statusBadgeBg(s);
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedStatus = s);
                        setSheet(() {});
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter list berdasarkan status yang dipilih
    List<Map<String, dynamic>> filteredIssues = _selectedStatus == null
        ? issues
        : issues.where((i) => i['status'] == _selectedStatus).toList();

    filteredIssues.sort((a, b) => getPriorityOrder(a['priority'] ?? '')
        .compareTo(getPriorityOrder(b['priority'] ?? '')));

    final hasFilter = _selectedStatus != null;

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
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Kasus'),
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
              fontWeight: FontWeight.w600, fontSize: 22, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── SEARCH + FILTER ICON ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
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
                  const SizedBox(width: 10),
                  // Filter icon button
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: hasFilter ? primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasFilter ? primary : Colors.grey.shade200,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: hasFilter ? Colors.white : Colors.grey.shade600,
                          ),
                          if (hasFilter)
                            Positioned(
                              top: 8, right: 8,
                              child: Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── ACTIVE FILTER CHIP ────────────────────────────────────────
            if (hasFilter)
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Row(
                  children: [
                    const Text('Filter: ',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusBadgeBg(_selectedStatus)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _statusBadgeBg(_selectedStatus)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _statusLabel(_selectedStatus),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusBadgeBg(_selectedStatus),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() => _selectedStatus = null);
                              fetchIssues();
                            },
                            child: Icon(Icons.close, size: 14,
                                color: _statusBadgeBg(_selectedStatus)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ── LIST KASUS ────────────────────────────────────────────────
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
                                color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: filteredIssues.length,
                          itemBuilder: (context, index) {
                            final issue = filteredIssues[index];
                            final status = issue['status']?.toString();
                            final priority = issue['priority']?.toString();
                            final isResolved = status == 'Resolved';
                            final isRejected = status == 'Rejected';
                            final deadline = issue['deadline'];
                            final isOverdue = _isOverdue(deadline, status);

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
                                  // ── CARD SELALU PUTIH ──
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── BARIS JUDUL & STATUS BADGE ──────
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            issue['title'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // STATUS BADGE BERWARNA
                                        _buildStatusBadge(status, isRejected),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // ── PRIORITY BADGE ───────────────────
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _priorityColor(priority)
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color:
                                                  _priorityColor(priority),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            _priorityLabel(priority),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: _priorityColor(priority),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // ── LOKASI ───────────────────────────
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 13,
                                            color: Colors.grey.shade500),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            issue['location'] ?? '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    Colors.grey.shade600),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // ── DEADLINE ─────────────────────────
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 13,
                                          color: isOverdue
                                              ? Colors.red
                                              : Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Deadline: ${_formatDeadline(deadline)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOverdue
                                                ? Colors.red
                                                : Colors.grey.shade600,
                                            fontWeight: isOverdue
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        if (isOverdue &&
                                            !isResolved &&
                                            !isRejected) ...[
                                          const SizedBox(width: 4),
                                          const Text(
                                            '(TERLAMBAT!)',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.red,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                        ]
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // ── FOOTER: tanggal & lihat detail ──
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          issue['created_at'] != null
                                              ? 'Dibuat: ${issue['created_at'].toString().substring(0, 10)}'
                                              : '',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  Colors.grey.shade500),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Lihat Detail",
                                              style: TextStyle(
                                                color: primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(Icons.arrow_forward,
                                                color: primary, size: 14),
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

  Widget _buildStatusBadge(String? status, bool isRejected) {
    final bg = _statusBadgeBg(status);
    final icon = _statusIcon(status);
    final label = _statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}