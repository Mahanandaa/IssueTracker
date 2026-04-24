import 'package:flutter/material.dart';
import 'package:issuetracker/admin/panggil_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const kPrimary = Color(0xFF3B6FF0);
const kPrimaryLight = Color(0xFFEEF2FF);
const kSurface = Color(0xFFF8F9FC);
const kBorder = Color(0xFFE2E8F0);
const kText = Color(0xFF1A202C);
const kSubtext = Color(0xFF718096);

class DetailLaporanAdmin extends StatefulWidget {
  final String issueId;
  const DetailLaporanAdmin({super.key, required this.issueId});

  @override
  State<DetailLaporanAdmin> createState() => _DetailLaporanAdminState();
}

class _DetailLaporanAdminState extends State<DetailLaporanAdmin> {
  final supabase = Supabase.instance.client;
  final commentController = TextEditingController();

  bool isLoading = true;
  bool isSendingComment = false;
  Map<String, dynamic>? issue;
  List<Map<String, dynamic>> comments = [];
  List<Map<String, dynamic>> spareParts = [];

  String get _uid => supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    fetchIssueDetail();
    fetchComments();
    fetchSpareParts();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> fetchIssueDetail() async {
    try {
      final response = await supabase
          .from('issues')
          .select()
          .eq('id', widget.issueId)
          .maybeSingle();
      if (mounted) {
        setState(() {
          issue = response;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("fetchIssueDetail error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> fetchComments() async {
    try {
      final response = await supabase
          .from('comments')
          .select('id, comment, created_at, user_id, users(name, role)')
          .eq('issue_id', widget.issueId)
          .order('created_at', ascending: true);
      if (mounted) {
        setState(() {
          comments = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('fetchComments error: $e');
    }
  }

  Future<void> fetchSpareParts() async {
    try {
      final response = await supabase
          .from('spare_parts')
          .select('part_name, quantity, notes')
          .eq('issue_id', widget.issueId)
          .order('created_at', ascending: true);
      if (mounted) {
        setState(() {
          spareParts = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('fetchSpareParts error: $e');
    }
  }

  Future<void> hapusKomentar(String commentId) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Hapus Komentar',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: kSubtext))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (konfirmasi != true) return;
    await supabase.from('comments').delete().eq('id', commentId);
    await fetchComments();
  }

  Future<void> kirimKomentar() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => isSendingComment = true);
    try {
      await supabase.from('comments').insert({
        'issue_id': widget.issueId,
        'user_id': _uid,
        'comment': text,
      });
      commentController.clear();
      await fetchComments();
    } catch (e) {
      if (mounted) _showSnack('Gagal kirim komentar: $e');
    } finally {
      if (mounted) setState(() => isSendingComment = false);
    }
  }

  Future<void> _tolakLaporan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Tolak Laporan',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Yakin ingin menolak laporan ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: kSubtext))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tolak',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await supabase
          .from('issues')
          .update({'status': 'Rejected'}).eq('id', widget.issueId);
      if (mounted) {
        setState(() {
          issue = {...?issue, 'status': 'Rejected'};
        });
        _showSnack('Laporan ditolak.');
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatTanggal(String? raw) {
    if (raw == null) return '-';
    try {
      return raw.substring(0, 16).replaceAll('T', ' ');
    } catch (_) {
      return raw;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Resolved':
        return const Color(0xFF38A169);
      case 'Rejected':
        return const Color(0xFFE53E3E);
      case 'In Progress':
        return kPrimary;
      case 'Pending':
        return const Color(0xFFD69E2E);
      default:
        return kSubtext;
    }
  }

  Color _priorityColor(String? p) {
    switch (p) {
      case 'Urgent':
        return const Color(0xFFC05621);
      case 'High':
        return const Color(0xFFE53E3E);
      case 'Medium':
        return const Color(0xFFD69E2E);
      default:
        return const Color(0xFF38A169);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: kPrimary)));
    }
    if (issue == null) {
      return const Scaffold(
          body: Center(child: Text("Data tidak ditemukan")));
    }

    final String currentStatus = issue?['status']?.toString() ?? '';
    final bool isRejected = currentStatus == 'Rejected';
    final bool isAlreadyAssigned = currentStatus == 'Assigned' ||
        currentStatus == 'In Progress' ||
        currentStatus == 'Resolved';
    final resolutionNotes = issue?['resolution_notes']?.toString() ?? '';
    final hasResolution = resolutionNotes.isNotEmpty;
    final priority = issue?['priority']?.toString();

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kText),
        title: const Text("Detail Laporan",
            style: TextStyle(
                fontWeight: FontWeight.w700, color: kText, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [

            // ── Judul + status ────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          issue?['title']?.toString() ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: kText),
                        ),
                      ),
                      // Badge prioritas
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _priorityColor(priority).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          priority ?? '-',
                          style: TextStyle(
                              color: _priorityColor(priority),
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Badge status
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(currentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentStatus.isNotEmpty ? currentStatus : '-',
                      style: TextStyle(
                          color: _statusColor(currentStatus),
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: [
                _infoTile(Icons.category_outlined, 'Kategori',
                    issue?['category']?.toString() ?? '-'),
                _infoTile(Icons.location_on_outlined, 'Lokasi',
                    issue?['location']?.toString() ?? '-'),
                _infoTile(Icons.calendar_today_outlined, 'Dibuat',
                    _formatTanggal(issue?['created_at']?.toString().substring(0, 10))),
                _infoTile(Icons.lock_clock_rounded, 'Deadline',
                    issue?['deadline'] != null
                        ? issue!['deadline'].toString().substring(0, 10)
                        : '-'),
              ],
            ),

            const SizedBox(height: 16),

            _sectionTitle('Deskripsi'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Text(
                issue?['description']?.toString() ?? '-',
                style: const TextStyle(fontSize: 14, color: kText, height: 1.5),
              ),
            ),

            const SizedBox(height: 16),

            // ── Foto ──────────────────────────────────────
            _sectionTitle('Foto Pengerjaan'),
            const SizedBox(height: 8),
            Row(
              children: [
                _fotoCard('Sebelum\n(Pelapor)',
                    issue?['photo_url']?.toString()),
                const SizedBox(width: 10),
                _fotoCard('Sesudah\n(Teknisi)',
                    issue?['completion_photo_url']?.toString()),
              ],
            ),

            // ── Langkah perbaikan ─────────────────────────
            if (hasResolution) ...[
              const SizedBox(height: 16),
              _sectionTitle('Langkah Perbaikan'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimary.withOpacity(0.3)),
                ),
                child: Text(resolutionNotes,
                    style: const TextStyle(
                        fontSize: 14, color: kText, height: 1.5)),
              ),
            ],

            // ── Spare parts ───────────────────────────────
            if (spareParts.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Spare Part Digunakan'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  children: spareParts.map((part) {
                    final isLast = part == spareParts.last;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(
                                bottom: BorderSide(color: kBorder)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.build_outlined,
                              size: 16, color: kSubtext),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              part['part_name']?.toString() ?? '-',
                              style: const TextStyle(
                                  fontSize: 13, color: kText),
                            ),
                          ),
                          Text(
                            'x${part['quantity'] ?? 0}',
                            style: const TextStyle(
                                color: kPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Banner rejected ───────────────────────────
            if (isRejected)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE53E3E).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Color(0xFFE53E3E)),
                    SizedBox(width: 10),
                    Text('Laporan ini telah ditolak',
                        style: TextStyle(
                            color: Color(0xFFE53E3E),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

            // ── Banner assigned ───────────────────────────
            if (isAlreadyAssigned && !isRejected)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: kPrimary),
                    const SizedBox(width: 10),
                    Text(
                      'Laporan sedang $currentStatus',
                      style: const TextStyle(
                          color: kPrimary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ── Komentar ──────────────────────────────────
            _sectionTitle('Komentar'),
            const SizedBox(height: 10),

            ...comments.map((c) {
              final bool isMine = c['user_id']?.toString() == _uid;
              final userMap = c['users'] as Map<String, dynamic>?;
              final namaUser = userMap?['name'] ?? 'Unknown';
              final waktu = _formatTanggal(c['created_at']?.toString());

              return Align(
                alignment:
                    isMine ? Alignment.centerRight : Alignment.centerLeft,
                child: GestureDetector(
                  onLongPress: isMine
                      ? () => hapusKomentar(c['id'].toString())
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMine ? kPrimaryLight : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isMine
                            ? const Radius.circular(12)
                            : Radius.zero,
                        bottomRight: isMine
                            ? Radius.zero
                            : const Radius.circular(12),
                      ),
                      border: Border.all(
                          color: isMine
                              ? kPrimary.withOpacity(0.2)
                              : kBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: isMine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(namaUser,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isMine ? kPrimary : kSubtext)),
                        const SizedBox(height: 4),
                        Text(c['comment']?.toString() ?? '',
                            style: const TextStyle(
                                fontSize: 14, color: kText)),
                        const SizedBox(height: 4),
                        Text(waktu,
                            style: const TextStyle(
                                fontSize: 11, color: kSubtext)),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // ── Input komentar ────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => kirimKomentar(),
                    style: const TextStyle(color: kText, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      hintStyle:
                          const TextStyle(color: kSubtext, fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            const BorderSide(color: kPrimary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                isSendingComment
                    ? const SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                            color: kPrimary, strokeWidth: 2))
                    : Material(
                        color: kPrimary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: kirimKomentar,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.send_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Tombol aksi admin ─────────────────────────
            if (!isRejected && !isAlreadyAssigned) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PanggilTeknisi(issueId: widget.issueId)),
                    );
                    if (result == true) fetchIssueDetail();
                  },
                  icon: const Icon(Icons.engineering_outlined,
                      color: Colors.white, size: 18),
                  label: const Text('Panggil Teknisi',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _tolakLaporan,
                  icon: const Icon(Icons.cancel_outlined,
                      color: Color(0xFFE53E3E), size: 18),
                  label: const Text('Tolak Laporan',
                      style: TextStyle(
                          color: Color(0xFFE53E3E),
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE53E3E)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 15, color: kText));
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kSubtext),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: kSubtext, fontSize: 10)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: kText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fotoCard(String label, String? url) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          children: [
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: kSubtext)),
            const SizedBox(height: 8),
            url != null && url.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      url,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fotoPlaceholder(),
                    ),
                  )
                : _fotoPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _fotoPlaceholder() {
    return Container(
      height: 130,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: kSurface, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 28, color: Colors.grey.shade400),
          const SizedBox(height: 4),
          Text('Belum ada foto',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
        ],
      ),
    );
  }
}