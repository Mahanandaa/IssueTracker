import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailLaporanKaryawan extends StatefulWidget {
  final String issueId;

  const DetailLaporanKaryawan({super.key, required this.issueId});

  @override
  State<DetailLaporanKaryawan> createState() =>
      _DetailLaporanKaryawanState();
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
  bool _sudahDinilai = false;
  int _selectedRating = 0; // 0 = belum pilih, 1-5 = nilai bintang

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
        if (response != null) _cekSudahDinilai();
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _cekSudahDinilai() async {
    try {
      final existing = await supabase
          .from('ratings')
          .select('id')
          .eq('issue_id', widget.issueId)
          .maybeSingle();
      if (mounted) setState(() => _sudahDinilai = existing != null);
    } catch (_) {}
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
    } catch (_) {}
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
            SnackBar(content: Text('Gagal kirim komentar: $e')));
      }
    } finally {
      if (mounted) setState(() => isSendingComment = false);
    }
  }

  Future<void> hapusKomentar(String commentId) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Komentar'),
        content: const Text('Yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (konfirmasi != true) return;
    await supabase.from('comments').delete().eq('id', commentId);
    await fetchComments();
  }

 Future<void> kirimUlasan() async {
  final technicianId = issue?['assigned_to'] as String?;

  final nilai = int.tryParse(rate.text);

  if (nilai == null || nilai < 1 || nilai > 5) {
    throw Exception('Rating tidak valid');
  }

  await supabase.from('ratings').insert({
    'rating': nilai,
    'feedback': feedback.text.trim(),
    'issue_id': widget.issueId,
    if (technicianId != null) 'technician_id': technicianId,
  });
}




  String _formatDeadline(dynamic raw) {
    if (raw == null) return 'Tidak ada deadline';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return raw.toString();
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

  Widget _fotoCard(String label, String? url) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            url != null && url.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      url,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Text('Gagal memuat foto',
                              style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : Container(
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Belum ada foto',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ),
          ],
        ),
      ),
    );
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

    final status = issue?['status']?.toString();

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
            Text(issue?['title']?.toString() ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 24)),
            const SizedBox(height: 20),

            Row(children: [
              _infoBox(
                  'Kategori', issue?['category']?.toString() ?? ''),
              const SizedBox(width: 12),
              _infoBox('Lokasi', issue?['location']?.toString() ?? ''),
            ]),
            const SizedBox(height: 14),

            Row(children: [
              _infoBox(
                  'Tanggal',
                  _formatTanggal(issue?['created_at']
                      ?.toString()
                      .substring(0, 10))),
              const SizedBox(width: 12),
              _infoBox('Status', issue?['status']?.toString() ?? ''),
            ]),
            const SizedBox(height: 14),

            // Deadline
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text(
                    'Deadline: ${_formatDeadline(issue?['deadline'])}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Deskripsi
            const Text('Deskripsi',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 20)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(issue?['description']?.toString() ?? ''),
            ),

            const SizedBox(height: 20),

            const Text('Foto Pengerjaan',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              children: [
                _fotoCard('Sebelum', issue?['photo_url']?.toString()),
                const SizedBox(width: 12),
                _fotoCard('Sesudah',
                    issue?['completion_photo_url']?.toString()),
              ],
            ),
            const SizedBox(height: 20),
            if (issue?['resolution_notes'] != null &&
                (issue!['resolution_notes'] as String).isNotEmpty) ...[
              const Text('Catatan Solusi',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 18)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(issue!['resolution_notes'].toString()),
              ),
              const SizedBox(height: 20),
            ],
            const Text('Komentar',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 10),
            ...comments.map((c) {
              final bool isMine = c['user_id']?.toString() == _uid;
              final userMap = c['users'] as Map<String, dynamic>?;
              final namaUser = userMap?['name'] ?? 'Unknown';
              final waktu =
                  _formatTanggal(c['created_at']?.toString());
              return Align(
                alignment: isMine
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
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
                        Text(namaUser,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isMine
                                  ? Colors.blue.shade800
                                  : Colors.grey.shade700,
                            )),
                        const SizedBox(height: 4),
                        Text(c['comment']?.toString() ?? ''),
                        const SizedBox(height: 4),
                        Text(waktu,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
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
                        child: CircularProgressIndicator(strokeWidth: 2))
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

            // Form feedback/rating hanya jika Resolved
            if (status == 'Resolved') ...[
              const Text('Feedback & Rating',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 10),
              if (_sudahDinilai) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Anda sudah memberikan rating & feedback.',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ] else ...[
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
// HANYA BAGIAN YANG DIUBAH

// HAPUS INI
// int _selectedRating = 0;

// =======================
// GANTI BAGIAN INI:
// =======================

const Text('Rating (1–5)',
    style: TextStyle(
        fontWeight: FontWeight.w600, fontSize: 18)),
const SizedBox(height: 10),

TextField(
  controller: rate,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(1),
  ],
  decoration: InputDecoration(
    hintText: 'Masukkan rating 1 - 5',
    prefixIcon: const Icon(Icons.star, color: Colors.orange),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
),

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: () async {
      final nilai = int.tryParse(rate.text);

      if (nilai == null || nilai < 1 || nilai > 5 || feedback.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating harus 1-5 dan isi feedback'),
          ),
        );
        return;
      }

      await kirimUlasan();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil Terkirim!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardKaryawan(),
          ),
        );
      }
    },
    child: const Text('Kirim Penilaian',
        style: TextStyle(color: Colors.white)),
  ),
),
                const SizedBox(height: 30),
              ],
            ],
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}