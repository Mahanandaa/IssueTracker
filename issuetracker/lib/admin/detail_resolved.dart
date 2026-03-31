import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';
class DetailResolved extends StatefulWidget {
const DetailResolved({super.key});
  @override
  State<DetailResolved> createState() => _DetailResolvedState();
}

class _DetailResolvedState extends State<DetailResolved> {
  @override
  void initState(){
    super.initState();

  }
  List<Map<String, dynamic>> issues = [];
  Future<void> fetchIssues() async{
    final response  = await supabase.from('issues').select();
    setState(() {
      issues = List<Map<String, dynamic>>.from(response);
    });

  }
    Map<String, dynamic>? issue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Resolved"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            children: [
              Text(
                issue?['title'] ?? 'Not Found', style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 231, 243, 255),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Kategori'  ,style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[200],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            issue?['category'] ?? 'Not Found' , style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                              fontSize: 25
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 231, 243, 255),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Lokasi'  ,style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[200],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            issue?['location'] ?? 'Not Found' , style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                              fontSize: 25
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                    children: [
                       Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 231, 243, 255),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Tanggal'  ,style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[200],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            issue?['created_at'] ?? 'Not Found' , style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                              fontSize: 25
                            ),
                          )
                        ],
                      ),
                    ),

                     Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 231, 243, 255),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Tanggal'  ,style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[200],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            issue?['status'] ?? 'Not Found' , style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                              fontSize: 25
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Column(
                      children: [
                        Text(
                          'Deskripsi', style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),

                          ),
                          child: Text(
                            issue?['description'] ?? 'Not Found' , style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Foto' , style: TextStyle(
                        fontWeight: FontWeight.w700,

                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200)
                      ),
                      child: Text(
                        issue?['photo_url'] ?? "Not found",
                      ),
                    ),
                    
                    ],
                ),
            ],
        ),
      ),
    );
  }
}