import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KasusDitolak extends StatefulWidget {
  const KasusDitolak({super.key});

  @override
  State<KasusDitolak> createState() => _KasusDitolakState();
}

class _KasusDitolakState extends State<KasusDitolak> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> issues = [];

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    final response = await supabase
        .from('issues')
        .select()
        .eq('status', 'Rejected'); 

    setState(() {
      issues = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Kasus Ditolak"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: issues.isEmpty
            ? const Center(
                child: Text(
                  "Belum ada kasus ditolak",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: issues.length,
                itemBuilder: (context, index) {
                  final issue = issues[index];

                  final priority = issue['priority'] ?? 'Low';

                  Color priorityColor;
                  if (priority == 'Urgent') {
                    priorityColor = Colors.red;
                  } else if (priority == 'Medium') {
                    priorityColor = Colors.orange;
                  } else {
                    priorityColor = Colors.green;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                issue['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: priorityColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                priority,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // REASON
                        const Text(
                          "Alasan Penolakan",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          issue['reject_reason'] ?? 'Tidak ada alasan',
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                issue['location'] ?? 'Lokasi tidak diketahui',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}