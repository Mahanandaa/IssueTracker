import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PanggilTeknisi extends StatefulWidget {
  final String issueId;
  const PanggilTeknisi({super.key, required this.issueId});

  @override
  State<PanggilTeknisi> createState() => _PanggilTeknisiState();
}

class _PanggilTeknisiState extends State<PanggilTeknisi> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> teknisiList = [];
  Map<String, double> teknisiRatings = {}; // simpan rating per teknisi
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeknisi();
  }


  Future<void> fetchTeknisi() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('users')
          .select('id, name, phone, department, is_available')
          .eq('role', 'teknisi')
          .order('is_available', ascending: false);

      final List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(response);

      // Hitung rating per teknisi: sum(rating) / jumlah tugas selesai
      final Map<String, double> ratings = {};
      for (final t in list) {
        final uid = t['id'] as String;
        try {
          // Ambil semua rating untuk teknisi ini
          final ratingData = await supabase
              .from('ratings')
              .select('rating')
              .eq('technician_id', uid);
          final List rList = ratingData as List;

          // Hitung jumlah tugas selesai
          final resolvedData = await supabase
              .from('issues')
              .select('id')
              .eq('assigned_to', uid)
              .eq('status', 'Resolved');
          final int resolvedCount = (resolvedData as List).length;

          if (rList.isNotEmpty && resolvedCount > 0) {
            double total = 0;
            for (final r in rList) {
              final val = r['rating'];
              if (val != null) total += (val as num).toDouble();
            }
            // Rumus: total rating / jumlah tugas selesai
            ratings[uid] = total / resolvedCount;
          }
        } catch (_) {}
      }

      setState(() {
        teknisiList = list;
        teknisiRatings = ratings;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat teknisi: $e')),
        );
      }
    }
  }

  Future<void> panggilTeknisi(Map<String, dynamic> teknisi) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Panggil ${teknisi['name']} untuk menangani laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Panggil',
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // 1. Update issues: set assigned_to, status Assigned, assigned_at
      await supabase.from('issues').update({
        'assigned_to': teknisi['id'],
        'status': 'Assigned',
        'assigned_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.issueId);

      // 2. Set teknisi is_available = false
      await supabase
          .from('users')
          .update({'is_available': false})
          .eq('id', teknisi['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${teknisi['name']} berhasil dipanggil!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memanggil teknisi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Panggil Teknisi'),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : teknisiList.isEmpty
                ? const Center(child: Text('Tidak ada teknisi'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: teknisiList.length,
                    itemBuilder: (context, index) {
                      final teknisi = teknisiList[index];
                      final bool isAvailable = teknisi['is_available'] == true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAvailable
                                ? Colors.green.shade200
                                : Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar inisial
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: isAvailable
                                  ? Colors.green.shade100
                                  : Colors.grey.shade200,
                              child: Text(
                                (teknisi['name'] as String? ?? '?')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isAvailable
                                      ? Colors.green.shade700
                                      : Colors.grey,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Info teknisi
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teknisi['name'] ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    teknisi['department'] ?? 'Teknisi',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? Colors.green.shade50
                                          : Colors.orange.shade50,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isAvailable
                                            ? Colors.green.shade300
                                            : Colors.orange.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      isAvailable ? 'Available' : 'On Progress',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isAvailable
                                            ? Colors.green.shade700
                                            : Colors.orange.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Tampilkan rating
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 13, color: Colors.amber),
                                      const SizedBox(width: 3),
                                      Text(
                                        teknisiRatings[teknisi['id']] != null
                                            ? teknisiRatings[teknisi['id']]!
                                                .toStringAsFixed(1)
                                            : 'Belum ada',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Call
                            GestureDetector(
                              onTap: isAvailable
                                  ? () => panggilTeknisi(teknisi)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? Colors.green[700]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Call',
                                  style: TextStyle(
                                    color: isAvailable
                                        ? Colors.white
                                        : Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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