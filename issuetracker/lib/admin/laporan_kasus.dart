import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanKasus extends StatefulWidget {
  const LaporanKasus({super.key});

  @override
  State<LaporanKasus> createState() => _LaporanKasusState();
}

class _LaporanKasusState extends State<LaporanKasus> {
  
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> issues = [];

  bool _isLoading = false;
  
   Future<void> fetchIssues() async {
    final response = await supabase.from('issues').select();

    setState(() {
      issues = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> fenchData([String? searchTerm]) async {

    setState(() {
      _isLoading = true;
    });

 

      var query = supabase.from('issues').select();

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = supabase
            .from('issues')
            .select()
            .or('title.ilike.%$searchTerm%,location.ilike.%$searchTerm%,priority.ilike.%$searchTerm%');
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Laporan"),
        backgroundColor: Colors.grey[200],

      ),
   body: SafeArea(
    child: Padding(padding: EdgeInsetsGeometry.all(12),
    
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text('Kasus : WiFi Error'),
            Text('Tanggal : 02 Februari 2026'),
            Text('Lokasi : Lantai 1'),
            Text('Kategori : Facilities'),
            Text('Prioritas  : Medium'),
            Text('Pelapor ananda'),
            Text('waktu 02:23:44'),
            Text('Status : Selesai'),
            Text('spear parts : KABEL LAN')
          ],
        ),
      ),
    
    ),
   ),
    );
  }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }}