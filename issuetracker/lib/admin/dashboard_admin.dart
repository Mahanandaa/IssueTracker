import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
 final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> issues = [];

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    final response = await supabase.from('issues').select();
    setState(() {
      issues = List<Map<String, dynamic>>.from(response);
    });
  }
  
  final SearchBar = TextEditingController();
  DateTime? selectedDate;
  bool _isLoading = false;
            String? selectedStatus;

  Future<void> fenchData([String? searchTerm]) async {
    setState(() {
      _isLoading = true;
    });
    try {
   var query = supabase.from('issues').select();
   if (searchTerm != null && searchTerm.isNotEmpty) {
  query = supabase.from('issues').select().or('title.ilike.%$searchTerm%, location.ilike.%$searchTerm%');
}
      final data = await query;
      setState(() {
        issues = List<Map<String, dynamic>>.from(data);
      });
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error : ${error.message}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  } 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("Dashboard"),
       
      ),
      body: SafeArea(child: SingleChildScrollView(
        padding: EdgeInsets.all(12),
       child:  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: SearchBar,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Cari kasus...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        fetchIssues();
                      } else {
                        fenchData(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.date_range_outlined,
                      color: Colors.blue[400], size: 28),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardAdmin()));
                              },
                ),
                Expanded(
        child: GestureDetector(
          onTap: () async {
            setState(() => selectedStatus = 'Hari Ini');
            fetchIssues();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selectedStatus == 'Hari Ini'
                  ? Colors.blue[700]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'Nari Ini',
                style: TextStyle(
                  color: selectedStatus == 'Hari Ini'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
       Expanded(
        child: GestureDetector(
          onTap: () async {
            setState(() => selectedStatus = 'Minggu Ini');
            fetchIssues();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selectedStatus == 'Minggu Ini'
                  ? Colors.blue[700]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'Minggu Ini',
                style: TextStyle(
                  color: selectedStatus == 'Minggu Ini'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 12),
                 Row(
                  children: [
                     Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(220, 245, 243, 243),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "Pemding",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "12",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(220, 245, 243, 243),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "Ditolak",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "12",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                         Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(220, 245, 243, 243),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "Progress",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "12",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(220, 245, 243, 243),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "Progress",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "12",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                      ],
                    )
                  ],
                  
                 ),
                    SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                           child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange[400],
                          borderRadius: BorderRadius.circular(12),
                          
                        ),
                          child: Column(
                          children: [
                            Text(
                              'Performa Teknisi',
                              style: TextStyle(
                                color: Colors.grey[400],
                              ),
                            ),
                            Text(
                              '9/10'
                            )
                          ],
                        )
                        )
                        ) 
                      ]
                    )
              ],
              
            ),
            
      ),
      
      ),
    );
  }
}