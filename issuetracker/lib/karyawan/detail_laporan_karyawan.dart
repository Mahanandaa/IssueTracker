import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailLaporanKaryawan extends StatefulWidget {
  const DetailLaporanKaryawan({super.key});

  @override
  State<DetailLaporanKaryawan> createState() => _DetailLaporanKaryawanState();
}

class _DetailLaporanKaryawanState extends State<DetailLaporanKaryawan> {

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> issues = [];
  @override
  void initState() {
    super.initState();
  }
  Future <void> fetchIssues() async {
    final response = await supabase.from('issues').select();
    setState(() {
      issues = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text(
          "Detail Laporan",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'WiFi tidak ada Internet',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 242, 242),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                      Text('Kategori',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey)),
                        SizedBox(height: 6),
                        Text('IT Equipment',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 242, 242),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Lokasi',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey)),
                        SizedBox(height: 6),
                        Text('Lantai satu',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 242, 242),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Tanggal',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey)),
                        SizedBox(height: 6),
                        Text('2 Februari 2026',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 242, 242),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Status',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey)),
                        SizedBox(height: 6),
                        Text('Progress',
                            style: TextStyle(
                                color: Color.fromARGB(255, 236, 138, 25),
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
              child: const Text(
                'Tidak ada koneksi internet di lantai 1 sejak tadi pagi',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 22),

            const Text('Foto',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),

            Container(
              height: 240,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
              child: const Text(
                'Tidak ada foto',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 22),

            const Text('Langkah - Langkah Perbaikan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),

            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
              child: const Text(
                'Laporan masih dalam pengerjaan',
                style: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 22),

            const Text('Feedback',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
              child: const TextField(
                maxLength: 250,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'tuliskan feedback',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text('Rating',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 2,
                decoration: const InputDecoration(
                  hintText: 'rating 1 - 10',
                  border: InputBorder.none,
                ),
              ),
            ),
            

const SizedBox(height: 22),

const Text(
  'Komentar',
  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
),
const SizedBox(height: 12),

Center(
  child: Container(
    width: MediaQuery.of(context).size.width * 0.9,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey, width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Admin',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          'Saya sudah memanggil teknisi untuk memperbaiki masalah',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    ),
  ),
),



const SizedBox(height: 10),

Center(
  child: Container(
    width: MediaQuery.of(context).size.width * 0.9,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey, width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Karyawan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(
          'Oke! Terimakasi banyak..!',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    ),
  ),
),


      SizedBox(height: 20),

            const SizedBox(height: 10),
 Row(
  children: [

    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, width: 0.5),
        ),
        child: const TextField(
        maxLines: null,
      maxLength: 250,
          decoration: InputDecoration(
            hintText: 'tulis komentar...',
            border: InputBorder.none,
            counterText: '',
          ),
        ),
      ),
    ),

    const SizedBox(width: 8),

    Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DetailLaporanKaryawan(),
            ),
          );
        },
      ),
    ),
  ],
),
      

SizedBox(height: 25),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DashboardKaryawan()),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 40),
            
          ],
        ),
      ),
    );
  }
}
