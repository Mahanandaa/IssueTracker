import 'package:flutter/material.dart';
import 'package:issuetracker/admin/panggil_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailLaporanAdmin extends StatefulWidget {
  final String issueId;

  const DetailLaporanAdmin({
    super.key,
    required this.issueId,
  });

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

  // Ambil detail laporan dari Supabase
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

  // Ambil daftar komentar
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

  // Kirim komentar baru
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (issue == null) {
      return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));
    }

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
            // Judul laporan
            Text(issue?['title']?.toString() ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 24)),
            const SizedBox(height: 20),

            Row(children: [
              _infoBox('Kategori',
                  issue?['category']?.toString() ?? 'Not Found'),
              const SizedBox(width: 12),
              _infoBox(
                  'Lokasi', issue?['location']?.toString() ?? 'Not Found'),
            ]),
            const SizedBox(height: 14),

            Row(children: [
              _infoBox(
                  'Tanggal',
                  _formatTanggal(
                      issue?['created_at']?.toString().substring(0, 10))),
              const SizedBox(width: 12),
              _infoBox(
                  'Status', issue?['status']?.toString() ?? 'Not Found'),
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
                        }[issue?['priority']?.toString()] ??
                        Colors.grey,
                    borderRadius: BorderRadius.circular(20),
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
            const SizedBox(height: 24),

            // Komentar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Komentar',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 20)),
                IconButton(
                  onPressed: fetchComments,
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  tooltip: 'Refresh komentar',
                ),
              ],
            ),
            const SizedBox(height: 10),

          comments.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Belum ada komentar.',
                          style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic)),
                    ),
                  )
                : Column(
                    children: comments.map((c) {
                      final isMine = c['user_id'] == _uid;
                      final namaUser =
                          c['users']?['name']?.toString() ?? 'Unknown';
                      final waktu =
                          _formatTanggal(c['created_at']?.toString().substring(0, 10));

                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
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
                                '$namaUser',
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
                                      fontSize: 11,
                                      color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 12),

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
                        child:
                            CircularProgressIndicator(strokeWidth: 2))
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

            // Tombol panggil teknisi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PanggilTeknisi(issueId: widget.issueId),
                    ),
                  );
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

            // Tombol tolak laporan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Tolak Laporan'),
                      content: const Text(
                          'Yakin ingin menolak laporan ini?'),
                      actions: [
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Batal')),
                        TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Tolak',
                                style:
                                    TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await supabase
                          .from('issues')
                          .update({'status': 'Rejected'}).eq(
                              'id', widget.issueId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Laporan ditolak.')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  }
                },
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