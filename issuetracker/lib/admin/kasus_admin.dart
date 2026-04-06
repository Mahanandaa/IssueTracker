import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:issuetracker/admin/data_admin.dart';
import 'package:issuetracker/admin/detail_laporan_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KasusAdmin extends StatefulWidget {
  const KasusAdmin({super.key});

  @override
  State<KasusAdmin> createState() => _KasusAdminState();
}

class _KasusAdminState extends State<KasusAdmin> {

  int getPriorityOrder(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 1;
      case 'high':
        return 2;
      case 'medium':
        return 3;
      case 'low':
        return 4;
      default:
        return 5;
    }
  }

  final supabase = Supabase.instance.client;
  int _currentIndex = 0;
  List<Map<String, dynamic>> issues = [];
  final search = TextEditingController();
  bool _isloading = false;
  String? selectedStatus = "All";

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

  Future<void> fenchData([String? searchTerm]) async {
    setState(() {
      _isloading = true;
    });

    try {
      var query = supabase.from('issues').select();

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = supabase
            .from('issues')
            .select()
            .or('title.ilike.%$searchTerm%,location.ilike.%$searchTerm%');
      }

      final data = await query;

      setState(() {
        issues = List<Map<String, dynamic>>.from(data);
      });
    } on PostgrestException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error : ${error.message}')),
      );
    } finally {
      setState(() {
        _isloading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredIssues = issues.where((issue) {
      if (selectedStatus == "All") return true;
      return issue['priority'] == selectedStatus;
    }).toList();

    filteredIssues.sort((a, b) {
      return getPriorityOrder(a['priority'] ?? '')
          .compareTo(getPriorityOrder(b['priority'] ?? ''));
    });
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work), label: 'Kasus'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storage_rounded), label: 'Data'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardAdmin(),
              ),
            );
          } else if (index == 1 ){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const KasusAdmin()));
          } else if (index == 2){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DataAdmin()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardAdmin()));
          }
        },
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("Kasus"),   
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xffe6e6e6),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: search,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Cari Kasus...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    fenchData(value);
                  },
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStatus = 'All';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedStatus == 'All'
                              ? Colors.blue
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(child: Text("All")),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStatus = 'Low';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedStatus == 'Low'
                              ? Colors.green
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(child: Text("Rendah")),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStatus = 'Medium';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedStatus == 'Medium'
                              ? Colors.orange
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(child: Text("Menengah")),
                      ),
                    ),
                  ),
                 const SizedBox(width: 8),
                  Expanded(
                  child: GestureDetector(
                  onTap: () {
                        setState(() {
                          selectedStatus = 'Hard';
                        });
                      },
                      child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                      color: selectedStatus == 'Hard'
                              ? Colors.deepOrange
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(child: Text("Sulit")),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStatus = 'Urgent';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedStatus == 'Urgent'
                              ? Colors.red
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(child: Text("Darurat")),
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 12),

              filteredIssues.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak Ada Laporan',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredIssues.length,
                      itemBuilder: (context, index) {

                        final issue = filteredIssues[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailLaporanAdmin(
                                  issueId: issue['id'].toString(),
                                ),
                              ),
                            );
                          },

                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: issue['priority'] == 'Urgent'
                                  ? const Color.fromARGB(255, 243, 77, 65)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                )
                              ]
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [

                            Expanded(
                            child: Text(
                              issue['title'] ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                
                              ),
                            ),
                          ),

                          Text(
                            issue['priority'] ?? '',
                            style: TextStyle(
                              color: {
                                'urgent': Colors.white,
                                'high': Colors.deepOrange,
                                'medium': Colors.orange,
                                'low': Colors.green,
                              }[issue['priority']?.toString().toLowerCase()] ?? Colors.black, 
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),

                                  ],
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Lokasi : ${issue['location'] ?? ''}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [

                                    Text(
                                      issue['created_at'] != null
                                          ? issue['created_at']
                                              .toString()
                                              .substring(0, 10)
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),

                                    const Text(
                                      "Lihat Detail",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),


            ],
          ),
        ),
      ),
    );
  }
}