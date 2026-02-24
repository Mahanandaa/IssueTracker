import 'package:flutter/material.dart';
import 'package:issuetracker/karyawan/detail_laporan_karyawan.dart';
import 'package:issuetracker/karyawan/edit_laporan.dart';
import 'package:issuetracker/karyawan/notifikasi_karyawan.dart';
import 'package:issuetracker/karyawan/setting_profile.dart';
import 'package:issuetracker/karyawan/tambah_laporan.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardKaryawan extends StatefulWidget {
  const DashboardKaryawan({super.key});

  @override
  State<DashboardKaryawan> createState() => _DashboardKaryawanState();
}

class _DashboardKaryawanState extends State<DashboardKaryawan> {
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

  Future<void> deleteIssues(dynamic id) async {
    try {
      await supabase.from('issues').delete().eq('id', id.toString());
      fetchIssues();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> confirmDelete(dynamic id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan Masalah'),
        content: const Text('Yakin ingin menghapus laporan masalah ini ? '),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      deleteIssues(id);
    }
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

  Future<void> _pickDate() async {
    
     DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
   
      try{
        final response = await supabase.from('issues').select('').eq('created_at' , '');
        print(response);
      }catch (a){
        print ('error $a');
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TambahLaporan()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selamat datang.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 26,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => NotifikasiKaryawan()),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.person, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => profilesettingkaryawan()),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),

            Row(
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
                      
                  onPressed: _pickDate,
                ),
              ],
            ),

            if (selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Tanggal: ${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

            const SizedBox(height: 20),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: Row(
    children: [

      Expanded(
        child: GestureDetector(
          onTap: () async {
            setState(() => selectedStatus = 'All');
            fetchIssues();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selectedStatus == 'All'
                  ? Colors.blue[700]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'All',
                style: TextStyle(
                  color: selectedStatus == 'All'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),

      const SizedBox(width: 8),

      Expanded(
        child: GestureDetector(
          onTap: () async {
            setState(() => selectedStatus = 'Pending');
            final response = await supabase
                .from('issues')
                .select()
                .eq('status', 'Pending');

            setState(() {
              issues = List<Map<String, dynamic>>.from(response);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selectedStatus == 'Pending'
                  ? Colors.blue[700]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'Pending',
                style: TextStyle(
                  color: selectedStatus == 'Pending'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),

      const SizedBox(width: 8),

      Expanded(
        child: GestureDetector(
          onTap: () async {
            setState(() => selectedStatus = 'Progress');
            final response = await supabase
                .from('issues')
                .select()
                .eq('status', 'In Progress');

            setState(() {
              issues = List<Map<String, dynamic>>.from(response);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selectedStatus == 'Progress'
                  ? Colors.blue[700]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'Progress',
                style: TextStyle(
                  color: selectedStatus == 'Progress'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),

      const SizedBox(width: 8),

      Expanded(
        child: GestureDetector(
          onTap: () async {
            setState(() => selectedStatus = 'Resolved');
            final response = await supabase
                .from('issues')
                .select()
                .eq('status', 'Resolved');

            setState(() {
              issues = List<Map<String, dynamic>>.from(response);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selectedStatus == 'Resolved'
                  ? Colors.blue[700]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'Resolved',
                style: TextStyle(
                  color: selectedStatus == 'Resolved'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 8),
      Expanded(
        child: GestureDetector(
          onTap: () async {
            setState(() => selectedStatus = 'Rejected');
            final response = await supabase
                .from('issues')
                .select()
                .eq('status', 'Rejected');

            setState(() {
              issues = List<Map<String, dynamic>>.from(response);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selectedStatus == 'Rejected'
                  ? Colors.red[700]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'Rejected',
                style: TextStyle(
                  color: selectedStatus == 'Rejected'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 8),
      Expanded(
        child: GestureDetector(
          onTap: () async {
            setState(() => selectedStatus = 'Escalated');
            final response = await supabase
                .from('issues')
                .select()
                .eq('status', 'Escalated');

            setState(() {
              issues = List<Map<String, dynamic>>.from(response);
            });
          },
          
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selectedStatus == 'Escalated'
                  ? Colors.orange[900]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'Escalated',
                style: TextStyle(
                  color: selectedStatus == 'Escalated'
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 30),
            Expanded(
              child: issues.isEmpty
                  ? const Center(
                      child: Text(
                        "Tidak ada laporan",
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          color: Colors.grey)
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                      itemCount: issues.length,
                      itemBuilder: (context, index) {
                        final issue = issues[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailLaporanKaryawan(),
                              ),
                            );
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius:
                                  BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      issue['title'] ?? '',
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.w600,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                              vertical: 5,
                                              horizontal: 8),
                                      decoration:
                                          BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius
                                                .circular(5),
                                      ),
                                      child: Text(
                                        issue['priority'] ??
                                            '',
                                        style: TextStyle(
                                          color: issue[
                                                      'priority'] ==
                                                  'Urgent'
                                              ? Colors.red
                                              : issue['priority'] ==
                                                      'High'
                                                  ? Colors.red
                                                  : issue[
                                                              'priority'] ==
                                                          'Medium'
                                                      ? Colors
                                                          .orange
                                                      : Colors
                                                          .green,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'Lokasi : ${issue['location'] ?? ''}'),
                                Text(
                                  issue['created_at'] != null
                                      ? issue['created_at'].toString().substring(0, 10): '',
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20),
                                      onPressed: () =>
                                          confirmDelete(
                                              issue['id']),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      child: Icon(
                                          Icons.edit_document,
                                          color: Colors
                                              .orange[900],
                                          size: 20),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  EditLaporan(
                                                      issue:
                                                          issue)),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                              vertical: 6,
                                              horizontal:
                                                  10),
                                      decoration:
                                          BoxDecoration(
                                        color: issue[ 'status'] == 'Pending'
                                            ? Colors
                                                .orange[100]
                                            : Colors
                                                .green[100],
                                        borderRadius:
                                            BorderRadius
                                                .circular(4),
                                      ),
                                      child: Text(
                                        issue['status'] ??
                                            '',
                                        style: TextStyle(
                                          color: issue[
                                                      'status'] ==
                                                  'Pending'
                                              ? Colors
                                                  .orange[900]
                                              : Colors
                                                  .green[900],
                                          fontWeight:
                                              FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}