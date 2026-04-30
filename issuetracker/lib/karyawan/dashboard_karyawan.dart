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

  String? _selectedCategory;

  final Color primary = const Color(0xFF2563EB);
  final Color bg = const Color(0xFFF8FAFC);

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
      final response =
          await supabase.from('issues').select().eq('reported_by', _uid);
      if (mounted) {
        setState(() {
          issues = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('fetchIssues error: $e');
      if (mounted) setState(() => _isLoading = false);
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

  // ── Deadline helpers ────────────────────────────────────────────────────

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
    if (raw == null ||
        status == 'Resolved' ||
        status == 'Rejected') return false;
    try {
      return DateTime.parse(raw.toString())
          .toLocal()
          .isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

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
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                              : Colors.blue,
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
    // Filter by category jika dipilih
    final displayIssues = _selectedCategory == null
        ? issues
        : issues
            .where((i) => i['category'] == _selectedCategory)
            .toList();

    final hasFilter = _selectedCategory != null;

    return Scaffold(
      backgroundColor: bg,

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text("Tambah", style: TextStyle(color: Colors.white)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 22),
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

            // ── SEARCH + FILTER CATEGORY ICON + DATE ────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  // Search bar
                  Expanded(
                    child: Container(
                      height: 48,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
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
                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: _showCategoryFilter,
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: hasFilter ? primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasFilter
                              ? primary
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: hasFilter
                                ? Colors.white
                                : Colors.blue.shade700
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
                  const SizedBox(width: 8),

                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.date_range, color: primary),
                      onPressed: _pickDate,
                    ),
                  ),
                ],
              ),
            ),

            if (hasFilter)
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Row(
                  children: [
                    const Text('Kategori: ',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey)),
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
                              setState(() => _selectedCategory = null);
                              fetchIssues();
                            },
                            child: Icon(Icons.close, size: 14,
                                color: primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

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
                                color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: displayIssues.length,
                          itemBuilder: (context, index) {
                            final issue = displayIssues[index];
                            final status = issue['status']?.toString();
                            final priority =
                                issue['priority']?.toString();
                            final isResolved = status == 'Resolved';
                            final isRejected = status == 'Rejected';
                            final isPending = status == 'Pending';
                            final deadline = issue['deadline'];
                            final isOverdue =
                                _isOverdue(deadline, status);

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
                              child: Container(
                                margin:
                                    const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  // ── CARD SELALU PUTIH ──
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // ── JUDUL & STATUS BADGE ───────
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            issue['title'] ?? '',
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w700,
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatusBadge(status),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // ── PRIORITY BADGE ─────────────
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3),
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
                                          color:
                                              _priorityColor(priority),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // ── KATEGORI (jika ada) ────────
                                    if (issue['category'] != null) ...[
                                      Row(
                                        children: [
                                          Icon(Icons.category_outlined,
                                              size: 13,
                                              color:
                                                  Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text(
                                            issue['category'],
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors
                                                    .grey.shade600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                    ],

                                    // ── LOKASI ─────────────────────
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            size: 13,
                                            color:
                                                Colors.grey.shade500),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            issue['location'] ?? '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors
                                                    .grey.shade600),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // ── DEADLINE ───────────────────
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 13,
                                            color: isOverdue
                                                ? Colors.red
                                                : Colors.grey.shade500),
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

                                    const SizedBox(height: 8),

                                    // ── FOOTER ─────────────────────
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
                                              fontSize: 12,
                                              color:
                                                  Colors.grey.shade500),
                                        ),
                                        if (isPending)
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          EditLaporan(
                                                              issue:
                                                                  issue),
                                                    ),
                                                  );
                                                  fetchIssues();
                                                },
                                                child: const Padding(
                                                  padding:
                                                      EdgeInsets.all(4),
                                                  child: Icon(
                                                      Icons.edit,
                                                      color:
                                                          Colors.orange,
                                                      size: 18),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              InkWell(
                                                onTap: () =>
                                                    confirmDelete(
                                                        issue['id']),
                                                child: const Padding(
                                                  padding:
                                                      EdgeInsets.all(4),
                                                  child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 18),
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
                                                  color: primary,
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(Icons.arrow_forward,
                                                  color: primary,
                                                  size: 14),
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

  Widget _buildStatusBadge(String? status) {
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