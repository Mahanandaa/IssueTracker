import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailTidakSelesai extends StatefulWidget {
  final String issueId; // ✅ simpan id

  const DetailTidakSelesai({
    super.key,
    required this.issueId,
  });

  @override
  State<DetailTidakSelesai> createState() =>
      _DetailTidakSelesaiState();
}

class _DetailTidakSelesaiState
    extends State<DetailTidakSelesai> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? issue;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIssue();
  }

  Future<void> fetchIssue() async {
    try {
      final response = await supabase
          .from('issues')
          .select()
          .eq('id', widget.issueId)
          .maybeSingle(); 
      setState(() {
        issue = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : issue == null
                ? const Center(child: Text("Data tidak ditemukan"))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                    Text(
                          issue?['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Alasan',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        _box(
                          issue?['not_completed_reason']
                                  ?.toString() ??
                              'Tidak ada alasan',
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Lokasi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        _box(
                          issue?['location']
                                  ?.toString() ??
                              '-',
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Foto Terakhir',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          child: issue?['photo_url'] != null
                              ? Image.network(
                                  issue!['photo_url'],
                                  fit: BoxFit.cover,
                                )
                              : const Center(
                                  child: Text(
                                      'Tidak ada foto'),
                                ),
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DashboardAdmin(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                            child: const Center(
                              child: Text(
                                'Kembali ke Dashboard',
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

  Widget _box(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(text),
    );
  }
}