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
  final comment = TextEditingController();
  Map<String, dynamic>? issue;
  bool isLoading = true;

Future<void> ulasan() async{
  await supabase.from('ratings').insert({
    'rating' : rate.text.trim(),
    'feedback' : feedback.text.trim(),
    'issue_id' : widget.issueId,
  });
}

Future<void> komentar() async{
  await supabase.from('comments').insert({
    'comment' : comment.text.trim(),
    'issue_id' : widget.issueId,
  });
}
  @override
  void initState() {
    super.initState();
    fetchIssueDetail();
  }

  Future<void> fetchIssueDetail() async {
    try {
      final response = await supabase.from('issues').select().eq('id', widget.issueId).maybeSingle();

      if (mounted) {
        setState(() {
          issue = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (issue == null) {
      return const Scaffold(
        body: Center(
          child: Text("Data tidak ditemukan"),
        ),
      );
    }

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
            Text(
              issue?['title']?.toString() ?? '',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 24),
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
                      children: [
                        const Text('Kategori',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey)),
                        Text(
                          issue?['category']?.toString() ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
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
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lokasi',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(
                          issue?['location']?.toString() ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
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
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(
                          issue?['created_at']?.toString() ?? '',
                          style: const TextStyle(fontSize: 16),
                        )
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
                      children: [
                        const Text('Status',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(
                          issue?['status']?.toString() ?? '',
                          style: const TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Deskripsi',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
              child: Text(
                issue?['description']?.toString() ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ),
           const SizedBox(height: 40),

const Text(
  'Foto',
  style: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 22,
  ),
),
const SizedBox(height: 10),
Container(
  height: 150,
  decoration: BoxDecoration(
  
    color: Colors.grey.shade200,
    borderRadius: BorderRadius.circular(14),
  ),
  child: const Center(
    child: Text(
      'Belum Ada Foto',
      style: TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: Colors.grey,
      ),
    ),
  ),
),

const SizedBox(height: 25),
Center(
child: const Text(
  'Langkah - Langkah Perbaikan',
  style: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 22,
  ),
),
),

const SizedBox(height: 10),
Container(
  height: 150,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey.shade300),
  ),
),

const SizedBox(height: 25),

const Text(
  'Ringkasan Solusi',
  style: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 22,
  ),
),
const SizedBox(height: 10),
Container(
  height: 150,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey.shade300),
  ),
),

const SizedBox(height: 25),

const Text(
  'Feedback',
  style: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 22,
  ),
),
const SizedBox(height: 10),
TextField(
  controller: feedback,
  maxLength: 250,
  maxLines: null,
  decoration: InputDecoration(
    prefixIcon: const Icon(Icons.send, color: Colors.blue),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
),

const SizedBox(height: 25),

const Text(
  'Rating',
  style: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 22,
  ),
),
const SizedBox(height: 10),
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
  controller: rate,
  maxLength: 2,
  decoration: InputDecoration(
    prefixIcon: const Icon(Icons.send, color: Colors.blue),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
),

const SizedBox(height: 25),

TextField(
  controller: comment,
  decoration: InputDecoration(
    hintText: 'Masukan komentar',
    
    prefixIcon: const Icon(Icons.send, color: Colors.blue),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
),

const SizedBox(height: 40),

Row(
children: [
    Expanded(child: SizedBox(
    height: 50,
    child: ElevatedButton(
    onPressed: () async{

      if(rate.text.isEmpty || feedback.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rating dan Feedback wajib diisi'),)
        );
        return;
      }
        try{
          await ulasan();
          await komentar();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: 
          Text('Berhasil Terkirim!')));
        } catch (a) {
          Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $a")),
    );  
     }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardKaryawan(),
        ),
      );
    },
    style: TextButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: const Text(
      'Selesai',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
  ),
),
  )
          ])
        ],
    ),
      ),
    );
  }
}