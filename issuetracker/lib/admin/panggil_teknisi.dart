import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';

class PanggilTeknisi extends StatefulWidget {
  const PanggilTeknisi({super.key});

  @override
  State<PanggilTeknisi> createState() => _PanggilTeknisiState();
}

String? selectedStatus;

class _PanggilTeknisiState extends State<PanggilTeknisi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Panggil Teknisi"),
        backgroundColor: Colors.grey,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              /// FILTER BUTTON
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          selectedStatus = "Escalated";
                        });

                        final response = await supabase
                            .from('issues')
                            .select()
                            .eq('status', 'Escalated');

                        setState(() {
                          issues = List<Map<String, dynamic>>.from(response);
                        });
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedStatus == "Escalated"
                              ? Colors.amber[700]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Tersedia",
                          style: TextStyle(
                            color: selectedStatus == "Escalated"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        setState(() {
                          selectedStatus = "Progress";
                        });

                        final response = await supabase
                            .from('issues')
                            .select()
                            .eq('status', 'Progress');

                        setState(() {
                          issues = List<Map<String, dynamic>>.from(response);
                        });
                      },
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedStatus == "Progress"
                              ? Colors.blue[700]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Progress",
                          style: TextStyle(
                            color: selectedStatus == "Progress"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Container(
                height: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text('Nama : Ananda'),
                    const Text('Role : Teknisi'),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status : Available'),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Call",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}