import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanKasus extends StatefulWidget {
  const LaporanKasus({super.key});

  @override
  State<LaporanKasus> createState() => _LaporanKasusState();
}

class _LaporanKasusState extends State<LaporanKasus> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> issues = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    try {
      final response = await supabase.from('issues').select();

      setState(() {
        issues = List<Map<String, dynamic>>.from(response);
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

  Future<void> searchIssues(String searchTerm) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.from('issues').select().or('title.ilike.%$searchTerm%, location.ilike.%$searchTerm%');
      setState(() {
        issues = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCard(Map<String, dynamic> item) {
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
          Text('Kasus: ${item['title'] ?? '-'}'),
          Text('Tanggal: ${item['created_at'].toString().substring(0, 10)}'),
          Text('Lokasi: ${item['location'] ?? '-'}'),
          Text('Kategori: ${item['category'] ?? '-'}'),
          Text('Prioritas: ${item['priority'] ?? '-'}'),
          Text('Pelapor: ${item['reporter'] ?? '-'}'),
          Text('Status: ${item['status'] ?? '-'}'),
          Text('Sparepart: ${item['sparepart'] ?? '-'}'),
        ],
      ),
    );
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
        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    fetchIssues();
                  } else {
                    searchIssues(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Cari laporan...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator())
                    : issues.isEmpty
                        ? const Center(
                            child: Text('Tidak ada data'))
                        : ListView.builder(
                            itemCount: issues.length,
                            itemBuilder: (context, index) {
                              final item = issues[index];
                              return buildCard(item);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}