import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/detail_laporan_teknisi.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';
import 'package:issuetracker/teknisi/notifikasi_teknisi.dart';
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
  final _searchController = TextEditingController();

  String? _selectedCategory;

  List<Map<String, dynamic>> issues = [];
  bool _isLoading = false;

  String get _uid => supabase.auth.currentUser?.id ?? '';

  final Color primary = const Color(0xFF2563EB);

  final List<String> _categories = [
    'Infrastruktur',
    'Kelistrikan',
    'Kebersihan',
    'Keamanan',
    'Lainnya',
  ];

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
          .inFilter('status', ['Assigned', 'In Progress', 'Resolved'])
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

  Future<void> fenchData([String? searchTerm]) async {
    if (_uid.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('issues')
          .select()
          .eq('assigned_to', _uid)
          .inFilter('status', ['Assigned', 'In Progress', 'Resolved'])
          .or('title.ilike.%$searchTerm%,location.ilike.%$searchTerm%')
          .order('assigned_at', ascending: false);

      if (mounted) {
        setState(() {
          issues = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDeadline(dynamic raw) {
    if (raw == null) return 'Tidak ada';
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
    if (raw == null || status == 'Resolved') return false;
    try {
      return DateTime.parse(raw.toString())
          .toLocal()
          .isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }


  Color _statusBadgeBg(String? status) {
    switch (status) {
      case 'Resolved':    return Colors.green;
      case 'Rejected':    return Colors.red.shade600;
      case 'In Progress': return primary;
      case 'Pending':     return Colors.orange;
      case 'Assigned':    return Colors.purple;
      default:            return Colors.grey;
    }
  }

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

  // ── PRIORITY helpers ────────────────────────────────────────────────────

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

  // ── Filter Category Bottom Sheet ────────────────────────────────────────

  void _showCategoryFilter() {
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
                  'Filter by Kategori',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Semua'),
                      selected: _selectedCategory == null,
                      selectedColor: primary,
                      labelStyle: TextStyle(
                        color: _selectedCategory == null
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategory = null);
                        setSheet(() {});
                        Navigator.pop(context);
                        fetchIssues();
                      },
                    ),
                    ..._categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                          setSheet(() {});
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
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
    // Filter by category
    final displayIssues = _selectedCategory == null
        ? issues
        : issues
            .where((i) => i['category'] == _selectedCategory)
            .toList();

    final hasFilter = _selectedCategory != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

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
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashboardTeknisi()));
          } else if (index == 1) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const HistoryTeknisi()));
          } else if (index == 2) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const Statistic()));
          } else if (index == 3) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const SettingProfileTeknisi()));
          }
        },
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => NotifikasiTeknisi()));
                    },
                    icon: const Icon(Icons.notifications, size: 28),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── SEARCH + FILTER CATEGORY ICON ──────────────────────
              Row(
                children: [
                  // Search bar
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E6E6),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
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
                  ),
                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: _showCategoryFilter,
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color:
                            hasFilter ? primary : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: hasFilter
                                ? Colors.white
                                : Colors.grey.shade700,
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

              // ── ACTIVE FILTER CHIP ─────────────────────────────────
              if (hasFilter) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Kategori: ',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCategory!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(
                                  () => _selectedCategory = null);
                              fetchIssues();
                            },
                            child: Icon(Icons.close,
                                size: 14, color: primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 18),

              const Text(
                "Tugas Terbaru",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              // ── LIST ───────────────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : displayIssues.isEmpty
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
                            itemCount: displayIssues.length,
                            itemBuilder: (context, index) {
                              final issue = displayIssues[index];
                              final status =
                                  issue['status']?.toString();
                              final priority =
                                  issue['priority']?.toString();
                              final isResolved =
                                  status == 'Resolved';
                              final isRejected =
                                  status == 'Rejected';
                              final overdue = _isOverdue(
                                  issue['deadline'], status);

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailLaporanTeknisi(
                                        issueId: issue['id']
                                            .toString(),
                                      ),
                                    ),
                                  ).then((_) => fetchIssues());
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    // ── CARD SELALU PUTIH ──
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.06),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── JUDUL & STATUS BADGE ──
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              issue['title'] ?? '',
                                              style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildStatusBadge(status),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // ── PRIORITY BADGE ─────────
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _priorityColor(
                                                  priority)
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _priorityColor(
                                                priority),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          _priorityLabel(priority),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _priorityColor(
                                                priority),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // ── LOKASI ─────────────────
                                      Row(
                                        children: [
                                          Icon(
                                              Icons.location_on_outlined,
                                              size: 13,
                                              color:
                                                  Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              "Lokasi: ${issue['location'] ?? 'Tidak diketahui'}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors
                                                    .grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      // ── DEADLINE ───────────────
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: overdue
                                                ? Colors.red
                                                : Colors.grey.shade500,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Deadline: ${_formatDeadline(issue['deadline'])}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: overdue
                                                  ? Colors.red
                                                  : Colors.grey.shade600,
                                              fontWeight: overdue
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          if (overdue) ...[
                                            const SizedBox(width: 4),
                                            const Text(
                                              '(Terlambat)',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.red,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      // ── FOOTER ─────────────────
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            issue['created_at'] != null
                                                ? issue['created_at']
                                                    .toString()
                                                    .substring(0, 10)
                                                : '',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  Colors.grey.shade500,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Lihat Detail",
                                                style: TextStyle(
                                                  color: primary,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(Icons.arrow_forward,
                                                  color: primary,
                                                  size: 12),
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
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    final bg = _statusBadgeBg(status);
    final icon = _statusIcon(status);
    final label = _statusLabel(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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