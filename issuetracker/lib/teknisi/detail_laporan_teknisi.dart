import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'progress_teknisi.dart';
import 'reject_laporan_teknisi.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();

class DetailLaporanTeknisi extends StatefulWidget {
  final String issueId;
  const DetailLaporanTeknisi({super.key, required this.issueId});

  @override
  State<DetailLaporanTeknisi> createState() => _DetailLaporanTeknisiState();
}

class _DetailLaporanTeknisiState extends State<DetailLaporanTeknisi> {
  final supabase = Supabase.instance.client;

Map<String, dynamic>? issue;
bool isSendingComment= false;
bool isLoading = true;
final commentController = TextEditingController();
List comments = [];
  String get _uid => supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    fetchDetail();
    fetchComments();
  }


  Future<void> fetchData() async {
    final i = await supabase
        .from('issues')
        .select()
        .eq('id', widget.issueId)
        .single();

    final c = await supabase
        .from('comments')
        .select()
        .eq('issue_id', widget.issueId);

    setState(() {
      issue = i;
      comments = c;
    });
  }
  
  Future<void> kirimKomentar() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => isSendingComment = true);
    try {
      await supabase.from('comments').insert({
        'issue_id': widget.issueId,
        'user_id': _uid,
        'comment': text,
      });
      commentController.clear();
      await fetchComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal kirim komentar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isSendingComment = false);
    }
  }

  Future<void> hapusKomentar(String commentId) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Komentar'),
        content: const Text('Yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (konfirmasi != true) return;
    await supabase.from('comments').delete().eq('id', commentId);
    await fetchComments();
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
   Future<void> fetchComments() async {
    try {
      final response = await supabase
          .from('comments')
          .select('id, comment, created_at, user_id, users(name, role)')
          .eq('issue_id', widget.issueId)
          .order('created_at', ascending: true);
      if (mounted) {
        setState(() {
          comments = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('fetchComments error: $e');
    }
  }

  Future<void> initNotification() async {
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: initSettingsAndroid);
    await notificationPlugin.initialize(settings: initSettings);
  }

  Future<void> showNotif(
      {int id = 0,
      required String title,
      required String body}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'issue_channel',
        'Issue Tracker',
        channelDescription: 'Notifikasi Status Laporan',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await notificationPlugin.show(
        id: id, title: title, body: body, notificationDetails: details);
  }

  Future<void> updateStatus() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase.from('users').update({
      'is_available': true,
    }).eq('id', userId);
  }

  Future<void> kirimNotifikasi() async {
    final issueData = await supabase
        .from('issues')
        .select('title, reported_by, assigned_to') 
        .eq('id', widget.issueId)
        .single();

    final judulIssue = issueData['title'] ?? 'Laporan';
    final karyawanId = issueData['reported_by'] as String?;
    final teknisId = issueData['assigned_to'] as String?;
    final admins =
        await supabase.from('users').select('id').eq('role', 'admin');

    final List<Map<String, dynamic>> notifList = [];

    if (karyawanId != null) {
      notifList.add({
        'user_id': karyawanId,
        'title': 'Laporan sedang dikerjakan!',
        'message': 'Laporan $judulIssue sedang dikerjakan!',
        'type': 'issue_in_progress',
        'is_read': false,
      });
    }

    if (teknisId != null) {
      notifList.add({
        'user_id': teknisId,
        'title': 'Kamu sedang mengerjakan!',
        'message': 'Kamu sedang menyelesaikan tugas $judulIssue',
        'type': 'new_task',
        'is_read': false,
      });
    }

    for (final admin in admins) {
      notifList.add({
        'user_id': admin['id'],
        'title': 'Laporan sedang dikerjakan',
        'message': 'Laporan $judulIssue sedang dikerjakan!',
        'type': 'issue_in_progress',
        'is_read': false,
      });
    }

    if (notifList.isNotEmpty) {
      await supabase.from('notifications').insert(notifList);
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
          .update({'is_available': true}).eq('id', _uid);

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
    case 'Urgent':
        return Colors.red;
    case 'High':
        return Colors.deepOrange;
    case 'Medium':
        return Colors.orange;
    default:
        return Colors.green;
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      case 'Assigned':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _fotoCard(String label, String? url) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04), blurRadius: 6)
          ],
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
                     const SizedBox(height: 8),
            url != null && url.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      url,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Text(
                          'Gagal memuat foto',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : Container(
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Belum ada foto',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
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
              // Card judul + status + prioritas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8)
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
                            issue!['title'] ?? '-',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
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
                                color:
                                    _priorityColor(issue!['priority'])),
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
                        border:
                            Border.all(color: _statusColor(status)),
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

              // Card info detail
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8)
                  ],
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
                          ? issue!['created_at']
                              .toString()
                              .substring(0, 10)
                          : '-',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Foto Pengerjaan',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _fotoCard(
                            'Sebelum', issue!['photo_url']?.toString()),
                        const SizedBox(width: 10),
                        _fotoCard('Sesudah',
                            issue!['completion_photo_url']?.toString()),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
Text(
  'Komentar' , 
  style: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 25,
  ),
),
SizedBox(height: 20),
  ...comments.map((c) {
  final bool isMine = c['user_id']?.toString() == _uid;
  final userMap = c['users'] as Map<String, dynamic>?;
  final namaUser = userMap?['name'] ?? 'Unknown';
  final waktu = c['created_at']?.toString().substring(0, 16) ?? '';

  return Align(
    alignment:
        isMine ? Alignment.centerRight : Alignment.centerLeft,
    child: GestureDetector(
      onLongPress: isMine
          ? () => hapusKomentar(c['id'].toString())
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? Colors.blue.shade100
              : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft:
                isMine ? const Radius.circular(12) : Radius.zero,
            bottomRight:
                isMine ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              namaUser,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isMine
                    ? Colors.blue.shade800
                    : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              c['comment']?.toString() ?? '',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              waktu,
              style: const TextStyle(
                  fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}),
                Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => kirimKomentar(),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade200)
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                isSendingComment
                    ? const SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                            strokeWidth: 2))
                    : Material(
                        color: Colors.blue,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: kirimKomentar,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.send,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
              ],
            ),
              const SizedBox(height: 24),

              if (isAssignedToMe && status == 'Assigned')
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            await kirimNotifikasi();
                            terimaTugas();
                            await showNotif(
                                title: 'Laporan Sedang Dikerjakan',
                                body:
                                    'Laporan sedang dikerjakan oleh teknisi');
                          },
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
                          onPressed: () async {
                            tolakTugas();
                            await updateStatus();
                          },
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
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
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
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[500])),
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