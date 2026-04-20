import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailResolved extends StatefulWidget {
  final String issueId;
  const DetailResolved({super.key, required this.issueId});

  @override
  State<DetailResolved> createState() => _DetailResolvedState();
}

class _DetailResolvedState extends State<DetailResolved> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? issue;
  Map<String, dynamic>? ratingData;
  List<Map<String, dynamic>> comments = [];
  List<Map<String, dynamic>> spareParts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // FIX 2,3: Ambil semua data dari DB
      final issueRes = await supabase
          .from('issues')
          .select()
          .eq('id', widget.issueId)
          .maybeSingle();

      final ratingRes = await supabase
          .from('ratings')
          .select('rating, feedback')
          .eq('issue_id', widget.issueId)
          .maybeSingle();

      final commentsRes = await supabase
          .from('comments')
          .select('comment, created_at, users(name)')
          .eq('issue_id', widget.issueId)
          .order('created_at', ascending: true);

      final sparePartsRes = await supabase
          .from('spare_parts')
          .select('part_name, quantity, notes')
          .eq('issue_id', widget.issueId)
          .order('created_at', ascending: true);

      setState(() {
        issue = issueRes;
        ratingData = ratingRes;
        comments = List<Map<String, dynamic>>.from(commentsRes);
        spareParts = List<Map<String, dynamic>>.from(sparePartsRes);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _infoBox(String label, String value, {Color? valueColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EEF3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.blue),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // FIX 2,3: Widget foto dari URL
  Widget _fotoBox(String label, String? url) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: url != null && url.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                            child: Text('Gagal memuat',
                                style: TextStyle(color: Colors.grey)))),
                  )
                : const Center(
                    child: Text('Belum Ada Foto',
                        style: TextStyle(color: Colors.grey))),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
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
          body: Center(child: Text('Data tidak ditemukan')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Detail Selesai"),
        backgroundColor: Colors.grey.shade200,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Judul
            Text(
              issue?['title'] ?? '-',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 20),
            ),
            const SizedBox(height: 10),

            // Kategori & Lokasi
            Row(
              children: [
                _infoBox('Kategori', issue?['category'] ?? '-'),
                const SizedBox(width: 10),
                _infoBox('Lokasi', issue?['location'] ?? '-'),
              ],
            ),
            const SizedBox(height: 10),

            // Tanggal & Status
            Row(
              children: [
                _infoBox(
                  'Tanggal',
                  issue?['created_at']?.toString().substring(0, 10) ??
                      '-',
                ),
                const SizedBox(width: 10),
                _infoBox('Status', issue?['status'] ?? '-',
                    valueColor: Colors.green),
              ],
            ),
            const SizedBox(height: 15),

            // Deskripsi
            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFE9EEF3),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(issue?['description'] ?? '-'),
            ),
            const SizedBox(height: 15),

            // Langkah perbaikan (resolution_notes)
            const Text('Langkah - Langkah Perbaikan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFE9EEF3),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(issue?['resolution_notes'] ??
                  'Tidak ada catatan'),
            ),
            const SizedBox(height: 15),

            // Waktu pengerjaan
            const Text('Waktu Pengerjaan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.orange[200],
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Durasi'),
                  Text(issue?['actual_time']?.toString() ?? '-',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Feedback & Rating dari DB
            const Text('Feedback & Rating',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (ratingData != null) ...[
              Row(
                children: [
                  _infoBox('Rating',
                      '${ratingData!['rating'] ?? '-'} / 5',
                      valueColor: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE9EEF3),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          const Text('Feedback',
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 5),
                          Text(
                            ratingData!['feedback'] ??
                                'Tidak ada feedback',
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFE9EEF3),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text(
                  'Belum ada rating dari karyawan',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            const SizedBox(height: 15),

            // FIX 3: Perbandingan foto sebelum dan sesudah dari DB
            const Text('Perbandingan Foto',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // photo_url = foto dari karyawan (sebelum)
                _fotoBox('Sebelum\n(Pelapor)',
                    issue?['photo_url']?.toString()),
                const SizedBox(width: 10),
                // completion_photo_url = foto dari teknisi (sesudah)
                _fotoBox('Sesudah\n(Teknisi)',
                    issue?['completion_photo_url']?.toString()),
              ],
            ),
            const SizedBox(height: 15),

            // Spare Parts
            const Text('Spare Parts',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (spareParts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFE9EEF3),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('Tidak ada spare parts',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              ...spareParts.map((sp) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE9EEF3),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.build_outlined,
                            size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sp['part_name'] ?? '-',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text('x${sp['quantity'] ?? 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                  )),

            const SizedBox(height: 15),

            // Komentar
            const Text('Komentar',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (comments.isEmpty)
              const Text('Belum ada komentar',
                  style: TextStyle(color: Colors.grey))
            else
              ...comments.map((c) {
                final userMap =
                    c['users'] as Map<String, dynamic>?;
                final namaUser = userMap?['name'] ?? 'Unknown';
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE9EEF3),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('$namaUser\n${c['comment'] ?? '-'}'),
                );
              }),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DashboardAdmin()),
                  );
                },
                child: const Text('Selesai',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}