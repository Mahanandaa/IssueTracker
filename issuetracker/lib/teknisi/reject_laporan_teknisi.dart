import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_teknisi.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();

class RejectLaporanTeknisi extends StatefulWidget {
final String issueId;
const RejectLaporanTeknisi({
super.key,
required this.issueId,
 });

  @override
  State<RejectLaporanTeknisi> createState() =>
      _RejectLaporanTeknisiState();
}

class _RejectLaporanTeknisiState extends State<RejectLaporanTeknisi> {

  final TextEditingController alasanController = TextEditingController();

  final supabase = Supabase.instance.client;
Future<void>rejectIssue() async{
    await Supabase.instance.client.from('issues').update({
          'status': 'Rejected',
          'reject_reason': alasanController.text.trim(),
        })
        .eq('id', widget.issueId)
        .select();
}



  Future<void> initNotification() async {
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

  }
  Future<void> showNotif({
    int id = 0,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'issue_channel',
        'Issue Tracker',
        channelDescription: 'Notifikasi status laporan',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

Future<void> kirimNotifikasi() async{
  final issue = await supabase.from('issues')
        .select('title, reported_by, assigned_to')
        .eq('id', widget.issueId)
        .single();
        final judulIssue = issue['title'] ?? 'Laporan';
        final karyawanId = issue['reported_by'] as String?;
        final teknisId = issue['assigned_to'] as String?;
        final admins = await supabase
        .from('users')
        .select('id')
        .eq('role', 'admin');
        final List<Map<String, dynamic>> notifList = [];
        if (karyawanId != null){
  notifList.add({
    'user_id' : karyawanId,
    'title' : 'Laporan Ditolak! ',
    'message' : 'Laporan $judulIssue ditolak teknisi',
    'type' : 'issue_rejected',
    'is_read' : false,
 
  
});
}

if(teknisId != null) {
  notifList.add({
    'user_id' : teknisId,
    'title' : "Tugas Ditolak!",
    'message' : "Kamu telah menolak laporan $judulIssue",
    'type' : 'task_completed',
    'is_read' : false,
  });
}
for (final admin in admins){
  notifList.add({
    'user_id' : admin['id'],
    'title' : 'Laporan Ditolak!',
    'message' : 'Laporan $judulIssue telah ditolak oleh teknisi'
  });
}
if (notifList.isNotEmpty){
  await supabase.from('notifications').insert(notifList);
}
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
    title: const Text("Tolak Laporan"),
    backgroundColor: Colors.grey[300],
      ),
    body: SafeArea(
    child: Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Alasan Tolak Kasus',
          style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
                ),
              ),

          const SizedBox(height: 12),

          TextField(
                controller: alasanController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Masukkan alasan penolakan...',
                  contentPadding: const EdgeInsets.all(14),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                   focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade700,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
onPressed: () async {
      await rejectIssue();
      await kirimNotifikasi();
      await showNotif(
       title: 'Laporan Ditolak',
       body: 'Laporan Ditolak Oleh Teknisi'
       
       );
  if (alasanController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Alasan tidak boleh kosong"),
      ),
    );
    return;
  }

  try {
   Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Laporan berhasil ditolak"),
      ),
    );
    Navigator.pushAndRemoveUntil(
     context,
     MaterialPageRoute(
       builder: (_) => const DashboardTeknisi(),
      ),
      (route) => false,
      
    );

  } catch (e) {

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );

  }

},
                  child: const Text(
                    'Kirim Alasan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),

                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}