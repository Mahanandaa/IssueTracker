import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailResolved extends StatefulWidget {
  const DetailResolved({super.key});

  @override
  State<DetailResolved> createState() => _DetailResolvedState();
}

class _DetailResolvedState extends State<DetailResolved> {
  
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> issues = [];
  Map<String, dynamic>? issue;

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    final response = await supabase.from('issues').select();
    setState(() {
      issues = List<Map<String, dynamic>>.from(response);
      if (issues.isNotEmpty) {
        issue = issues[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
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
            SizedBox(height: 10),
            Text(
              'Wifi Tidak Ada Internet',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20
              ),
            ),
                        SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EEF3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('Kategori', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 5),
                        Text(
                          issue?['category'] ?? 'Facilities',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EEF3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('Lokasi', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 5),
                        Text(
                          issue?['location'] ?? 'Lantai 1',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EEF3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('Tanggal', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 5),
                        Text(
                          issue?['created_at']?.toString().substring(0, 10) ??
                              '2 Februari 2026',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EEF3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('Status', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 5),
                        Text(
                          issue?['status'] ?? 'Resolved',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                issue?['description'] ??
                    'Tidak ada koneksi internet di lantai 1 sejak tadi pagi',
              ),
            ),

            const SizedBox(height: 15),

            const Text('Foto',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              height: 120,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Tidak ada foto',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 15),

            const Text('Langkah - Langkah perbaikan :',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
                            width: double.infinity,

              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                  '1. restart kembali router\n2. selesai'),
            ),

            const SizedBox(height: 15),

            const Text('Ringkasan Solusi',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
                            width: double.infinity,

              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                  'Lakukan restart ketika koneksi menghilang'),
            ),

            const SizedBox(height: 15),

            const Text('Feedback',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                  'teknisi bekerja sangat baik dan cepat'),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      children: [
                        Text('Rating'),
                        Text('9/10',
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      children: [
                        Text('Waktu'),
                        Text('01 : 23 : 55',
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text('Perbandingan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Belum Ada Foto'
                        ),
                      ),
                       const Text('Sebelum'),

                    ],
                    
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Belum Ada Foto'
                        ),
                      ),
                      const Text('Sesudah'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text('Komentar',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Admin\nSaya sudah mengirim teknisi'),
            ),

            const SizedBox(height: 8),

            Container(
                            width: double.infinity,

              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Ahmad\nOke, terimakasih!'),
            ),

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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DashboardAdmin()));
                },
                child: const Text('Selesai', style: TextStyle(
                  color: Colors.white
                ),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}