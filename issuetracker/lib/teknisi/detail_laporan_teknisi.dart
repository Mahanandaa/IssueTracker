import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'progress_teknisi.dart';       // sesuaikan path project kamu
import 'reject_laporan_teknisi.dart'; // sesuaikan path project kamu

class DetailLaporanTeknisi extends StatefulWidget {
  final String issueId;
  const DetailLaporanTeknisi({super.key, required this.issueId});

  @override
  State<DetailLaporanTeknisi> createState() => _DetailLaporanTeknisiState();
}

class _DetailLaporanTeknisiState extends State<DetailLaporanTeknisi> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? issue;
  bool isLoading = true;

  String get _uid => supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('issues')
          .select()
          .eq('id', widget.issueId)
          .maybeSingle();

      setState(() {
        issue = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void terimaTugas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgressTeknisi(issueId: widget.issueId),
      ),
    ).then((_) => fetchDetail());
  }

  void tolakTugas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RejectLaporanTeknisi(issueId: widget.issueId),
      ),
    ).then((_) => fetchDetail());
  }

  Future<void> selesaikanTugas() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selesaikan Tugas'),
        content: const Text('Tandai tugas ini sebagai selesai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Selesai',
                style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('issues').update({
        'status': 'Resolved',
        'resolved_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.issueId);

      await supabase
          .from('users')
          .update({'is_available': true})
          .eq('id', _uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil diselesaikan!'),
            backgroundColor: Colors.green,
          ),
        );
        fetchDetail();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }



  Color _priorityColor(String? p) {
    switch (p) {
      case 'Urgent': return Colors.red;
      case 'High':   return Colors.deepOrange;
      case 'Medium': return Colors.orange;
      default:       return Colors.green;
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'In Progress': return Colors.blue;
      case 'Resolved':    return Colors.green;
      case 'Assigned':    return Colors.orange;
      default:            return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (issue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Laporan')),
        body: const Center(child: Text('Laporan tidak ditemukan')),
      );
    }

    final status = issue!['status'] as String?;
    final isAssignedToMe = issue!['assigned_to'] == _uid;

    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            issue!['title'] ?? '-',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priorityColor(issue!['priority'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _priorityColor(issue!['priority'])),
                          ),
                          child: Text(
                            issue!['priority'] ?? '-',
                            style: TextStyle(
                              color: _priorityColor(issue!['priority']),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _statusColor(status)),
                      ),
                      child: Text(
                        status ?? '-',
                        style: TextStyle(
                          color: _statusColor(status),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Info detail ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.category_outlined, 'Kategori',
                        issue!['category'] ?? '-'),
                    _divider(),
                    _infoRow(Icons.location_on_outlined, 'Lokasi',
                        issue!['location'] ?? '-'),
                    _divider(),
                    _infoRow(Icons.description_outlined, 'Deskripsi',
                        issue!['description'] ?? '-'),
                    _divider(),
                    _infoRow(
                      Icons.calendar_today_outlined,
                      'Dilaporkan',
                      issue!['created_at'] != null
                          ? issue!['created_at'].toString().substring(0, 10)
                          : '-',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (isAssignedToMe && status == 'Assigned')
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: terimaTugas,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Terima Tugas',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        
                        height: 48,
                        child: ElevatedButton(
                          onPressed: tolakTugas,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Tolak Tugas',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (isAssignedToMe && status == 'In Progress')
                SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                onPressed: selesaikanTugas,
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
                   ),
                   child: const Text(
                        'Tandai Selesai',
                         style: TextStyle(
                         color: Colors.white,
                         fontWeight: FontWeight.bold,
                         fontSize: 16),
                   ),
                 ),
               ),
             if (status == 'Resolved')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Tugas Telah Diselesaikan',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey[200]);
}