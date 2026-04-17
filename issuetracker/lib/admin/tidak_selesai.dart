import 'package:flutter/material.dart';
import 'package:issuetracker/admin/detail_tidak_selesai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TidakSelesai extends StatefulWidget {
  const TidakSelesai({super.key});

  @override
  State<TidakSelesai> createState() => _TidakSelesaiState();
}

class _TidakSelesaiState extends State<TidakSelesai> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> issues = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    notCompleted();
  }

 Future<void> notCompleted() async {
  try {
    final response = await supabase
        .from('issues')
        .select()
          .eq('status', 'Escalated');

    if (response != null) {
      setState(() {
        issues = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    }
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
        title: const Text("Tidak Selesai"),
        backgroundColor: Colors.grey[200],
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : issues.isEmpty
                ? const Center(child: Text("Tidak ada data"))
                : ListView.builder(
                    itemCount: issues.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final item = issues[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 245, 242, 242),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                            )
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            Text(
                              item['title'] ?? 'No Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              item['not_completed_reason'] ??
                                  'Tidak ada alasan',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              item['reject_reason'] ??
                                  'Tidak ada penolakan',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['location'] ?? '-',
                                  style: const TextStyle(fontSize: 13),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DetailTidakSelesai(
                                          issueId: item['id'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Detail',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}