import 'package:flutter/material.dart';
import 'package:issuetracker/admin/panggil_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  String get _uid => supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    fetchIssueDetail();
    fetchComments();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal kirim komentar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isSendingComment = false);
    }
  }

  /// FIX 7: Tolak laporan dan update state lokal agar tombol hilang tanpa reload
  Future<void> _tolakLaporan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tolak Laporan'),
        content: const Text('Yakin ingin menolak laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tolak',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase
          .from('issues')
          .update({'status': 'Rejected'}).eq('id', widget.issueId);

      if (mounted) {
        // FIX 7: Update state lokal → tombol langsung hilang
        setState(() {
          issue = {...?issue, 'status': 'Rejected'};
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan ditolak.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _formatTanggal(String? raw) {
    if (raw == null) return '';
    try {
      return raw.substring(0, 16).replaceAll('T', ' ');
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (issue == null) {
      return const Scaffold(
          body: Center(child: Text("Data tidak ditemukan")));
    }

    // FIX 7: Cek status laporan untuk sembunyikan tombol aksi
    final String currentStatus = issue?['status']?.toString() ?? '';
    final bool isRejected = currentStatus == 'Rejected';
    final bool isAlreadyAssigned = currentStatus == 'Assigned' || currentStatus == 'In Progress' || currentStatus == 'Resolved';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Laporan"),
        backgroundColor: Colors.grey[200],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Judul
            Text(issue?['title']?.toString() ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 24)),
            const SizedBox(height: 20),

            Row(children: [
              _infoBox('Kategori',
                  issue?['category']?.toString() ?? 'Not Found'),
              const SizedBox(width: 12),
              _infoBox('Lokasi',
                  issue?['location']?.toString() ?? 'Not Found'),
            ]),
            const SizedBox(height: 14),

            Row(children: [
              _infoBox(
                  'Tanggal',
                  _formatTanggal(issue?['created_at']
                      ?.toString()
                      .substring(0, 10))),
              const SizedBox(width: 12),
              _infoBox('Status', currentStatus.isNotEmpty
                  ? currentStatus
                  : 'Not Found'),
            ]),
            const SizedBox(height: 20),

            // Deskripsi
            const Text('Deskripsi',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 20)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                  issue?['description']?.toString() ?? 'Not Found',
                  style: const TextStyle(fontSize: 15)),
            ),
            const SizedBox(height: 20),

            // Foto
            const Text('Foto',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: issue?['photo_url'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        issue!['photo_url'].toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('Gagal memuat foto',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('Belum Ada Foto',
                          style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic))),
            ),
            const SizedBox(height: 20),

            // Prioritas
            Row(
              children: [
                const Text('Prioritas: ',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: {
                          'Urgent': Colors.red,
                          'High': Colors.deepOrange,
                          'Medium': Colors.orange,
                          'Low': Colors.green,
                        }[issue?['priority']] ??
                        Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    issue?['priority']?.toString() ?? '-',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // FIX 7: Banner status jika sudah Rejected
            if (isRejected)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      'Laporan ini telah ditolak',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            if (isRejected) const SizedBox(height: 20),

            // Komentar
            const Text('Komentar',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 10),

            ...comments.map((c) {
              final bool isMine = c['user_id']?.toString() == _uid;
              final userMap =
                  c['users'] as Map<String, dynamic>?;
              final namaUser = userMap?['name'] ?? 'Unknown';
              final waktu =
                  _formatTanggal(c['created_at']?.toString());

              return Align(
                alignment: isMine
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isMine
                        ? Colors.blue.shade100
                        : Colors.grey.shade200,
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
                  ),
                  child: Column(
                    crossAxisAlignment: isMine
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaUser,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isMine
                              ? Colors.blue.shade800
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(c['comment']?.toString() ?? '',
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(waktu,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // Input komentar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => kirimKomentar(),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
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
                            strokeWidth: 2))
                    : Material(
                        color: Colors.blue,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: kirimKomentar,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.send,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 30),

            // FIX 7: Tombol aksi hanya tampil jika status BUKAN Rejected
            // dan belum di-assign
            if (!isRejected && !isAlreadyAssigned) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PanggilTeknisi(issueId: widget.issueId),
                      ),
                    );
                    // Refresh detail setelah kembali dari panggil teknisi
                    if (result == true) {
                      fetchIssueDetail();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Panggil Teknisi',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _tolakLaporan,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Tolak Laporan',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                ),
              ),
            ],

            // FIX 7: Tampilkan info jika sudah assigned
            if (isAlreadyAssigned)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(
                      'Laporan sedang $currentStatus',
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}