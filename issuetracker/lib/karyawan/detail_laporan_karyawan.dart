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

  // No. 4: flag apakah sudah pernah submit rating
  bool _sudahDinilai = false;

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

  Future<void> checkDeadlineAndNotify(Map<String, dynamic> issue) async {
    if (issue['deadline'] == null) return;
    final deadline = DateTime.parse(issue['deadline']);
    final now = DateTime.now();
    if (now.isAfter(deadline) && issue['status'] != 'Resolved') {
      final users = await supabase
          .from('users')
          .select()
          .inFilter('role', ['admin', 'teknisi']);
      for (var user in users) {
        await supabase.from('notifications').insert({
          'user_id': user['id'],
          'title': 'Deadline Terlewat',
          'message': 'Tugas "${issue['title']}" sudah melewati deadline',
          'type': 'new_task',
        });
      }
    }
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

        // No. 4: cek apakah user ini sudah memberi rating pada issue ini
        if (response != null) {
          _cekSudahDinilai();
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // No. 4: cek ke tabel ratings apakah sudah ada entry untuk issue_id ini
  Future<void> _cekSudahDinilai() async {
    try {
      final existing = await supabase
          .from('ratings')
          .select('id')
          .eq('issue_id', widget.issueId)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _sudahDinilai = existing != null;
        });
      }
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
    } catch (e) {}
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

  Future<void> kirimUlasan() async {
    await supabase.from('ratings').insert({
      'rating': int.tryParse(rate.text.trim()) ?? 0,
      'feedback': feedback.text.trim(),
      'issue_id': widget.issueId,
    });
  }

  // No. 1: format deadline
  String _formatDeadline(dynamic raw) {
    if (raw == null) return 'Tidak ada deadline';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
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
              _infoBox('Kategori', issue?['category']?.toString() ?? ''),
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

            // No. 1: tampilkan deadline
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

            const SizedBox(height: 24),

            const Text('Deskripsi',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
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

            const SizedBox(height: 30),

            if (status == 'Resolved') ...[
              const Text('Feedback',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 22)),
              const SizedBox(height: 10),

              // No. 4: jika sudah dinilai, tampilkan info saja
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
                      Text(
                        'Anda sudah memberikan rating & feedback.',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ] else ...[
                // Belum dinilai — tampilkan form
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

                const Text('Rating (1–5)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 22)),
                const SizedBox(height: 10),

                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: rate,
                  maxLength: 1,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 5',
                    prefixIcon:
                        const Icon(Icons.star, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (rate.text.isEmpty || feedback.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Rating dan Feedback wajib diisi')),
                        );
                        return;
                      }

                      final ratingVal = int.tryParse(rate.text.trim()) ?? 0;
                      if (ratingVal < 1 || ratingVal > 5) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Rating harus antara 1 sampai 5')),
                        );
                        return;
                      }

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
                    },
                    child: const Text('Selesai'),
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
            Text(label),
            const SizedBox(height: 6),
            Text(value),
          ],
        ),
      ),
    );
  }
}