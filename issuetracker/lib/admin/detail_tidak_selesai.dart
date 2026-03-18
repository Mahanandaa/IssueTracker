import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailTidakSelesai extends StatefulWidget {
  const DetailTidakSelesai({super.key});

  @override
  State<DetailTidakSelesai> createState() =>
      _DetailTidakSelesaiState();
}

class _DetailTidakSelesaiState
    extends State<DetailTidakSelesai> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? issue;
  List<Map<String, dynamic>> issues = [];

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    final response =
        await supabase.from('issues').select();

    setState(() {
      issues =
          List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Detail Tidak Selesai"),
        backgroundColor: Colors.grey[200],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text(
                'Listrik Konslet',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Alasan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),

              Container(
                width: double.infinity,
                height: 100,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  issue?['not_completed_reason']
                          ?.toString() ??
                      'Not Found',
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Lokasi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),

              Container(
                width: double.infinity,
                height: 100,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  issue?['location']
                          ?.toString() ??
                      ' not found',
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Foto Terakhir',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),

              Container(
                width: double.infinity,
                height: 100,
                child: Text(
                  issue?['photo_url']
                          ?.toString() ??
                      ' not found',
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DashboardTeknisi(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Kembali ke dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}