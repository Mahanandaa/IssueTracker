import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailLaporanKaryawan extends StatefulWidget {
  final String issueId;

  const DetailLaporanKaryawan({
    super.key,
    required this.issueId,
  });

  @override
  State<DetailLaporanKaryawan> createState() => _DetailLaporanKaryawanState();
}

class _DetailLaporanKaryawanState extends State<DetailLaporanKaryawan> {
  final supabase = Supabase.instance.client;
  final feedback = TextEditingController();
  final rate = TextEditingController();
  final commentController = TextEditingController();

  Map<String, dynamic>? issue;
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  bool isSendingComment = false;

  String get _uid => supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    fetchIssueDetail();
    fetchComments();
  }

  @override
  void dispose() {
    feedback.dispose();
    rate.dispose();
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

  // Simpan rating dan feedback ke Supabase
  Future<void> kirimUlasan() async {
    await supabase.from('ratings').insert({
      'rating': int.tryParse(rate.text.trim()) ?? 0,
      'feedback': feedback.text.trim(),
      'issue_id': widget.issueId,
    });
  }

  // Format tanggal dari ISO string ke "yyyy-MM-dd HH:mm"
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
        backgroundColor: Colors.grey[200],
        title: const Text("Detail Laporan",
            style: TextStyle(fontWeight: FontWeight.w600)),
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
              _infoBox('Kategori', issue?['category']?.toString() ?? ''),
              const SizedBox(width: 12),
              _infoBox('Lokasi', issue?['location']?.toString() ?? ''),
            ]),
            const SizedBox(height: 14),

            Row(children: [
              _infoBox('Tanggal',
                  _formatTanggal(issue?['created_at']?.toString())),
              const SizedBox(width: 12),
              _infoBox('Status', issue?['status']?.toString() ?? ''),
            ]),
            const SizedBox(height: 24),

            // Deskripsi
            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(issue?['description']?.toString() ?? '',
                  style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),

            // Foto
            const Text('Foto',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('Belum Ada Foto',
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 24),

            // Langkah perbaikan
            const Text('Langkah - Langkah Perbaikan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                issue?['resolution_notes']?.toString().isNotEmpty == true
                    ? issue!['resolution_notes'].toString()
                    : 'Belum ada catatan perbaikan.',
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 24),

            // Ringkasan solusi
            const Text('Ringkasan Solusi',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text('Belum tersedia.',
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
            ),
            const SizedBox(height: 30),

            // Komentar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Komentar',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 22)),
                IconButton(
                  onPressed: fetchComments,
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  tooltip: 'Refresh komentar',
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tampilkan daftar komentar atau pesan kosong
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
                      final roleUser =
                          c['users']?['role']?.toString() ?? '';
                      final roleLabel = roleUser.isNotEmpty
                          ? '(${roleUser[0].toUpperCase()}${roleUser.substring(1)})'
                          : '';
                      final waktu =
                          _formatTanggal(c['created_at']?.toString());

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
                                '$namaUser $roleLabel',
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
                    }).toList(),
                  ),

            const SizedBox(height: 12),

            // Input komentar baru
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
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Material(
                        color: Colors.blue,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: kirimKomentar,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child:
                                Icon(Icons.send, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
              ],
            ),

            const SizedBox(height: 30),

            // Feedback
            const Text('Feedback',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),
            TextField(
              controller: feedback,
              maxLength: 250,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Tulis feedback Anda...',
                prefixIcon:
                    const Icon(Icons.rate_review, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 16),

            // Rating
            const Text('Rating (1–5)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: rate,
              maxLength: 1,
              decoration: InputDecoration(
                hintText: 'Contoh: 5',
                prefixIcon:
                    const Icon(Icons.star, color: Colors.orange),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol selesai
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (rate.text.isEmpty || feedback.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Rating dan Feedback wajib diisi')),
                    );
                    return;
                  }
                  try {
                    await kirimUlasan();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Berhasil Terkirim!')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DashboardKaryawan()),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Selesai',
                    style: TextStyle(
                        color: Colors.white,
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
          color: const Color(0xFFF5F2F2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}