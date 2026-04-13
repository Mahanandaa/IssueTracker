import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();

class TidakSelesaiTeknisi extends StatefulWidget {
  final String issueId;
  const TidakSelesaiTeknisi({
    super.key,
    required this.issueId,
  });
  @override
  State<TidakSelesaiTeknisi> createState() => _TidakSelesaiTeknisiState();
}

class _TidakSelesaiTeknisiState extends State<TidakSelesaiTeknisi> {
  File? _imageFile;
  final ImagePicker picker = ImagePicker();
  final TextEditingController reject = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    reject.dispose();
    super.dispose();
  }

  // No. 8: Kembalikan issue ke Pending dan set assigned_to = null
  // agar issue hilang dari dashboard teknisi
  Future<void> tidakSelesai() async {
    await supabase.from('issues').update({
      'status': 'Pending',
      'not_completed_reason': reject.text.trim(),
      // No. 8: kosongkan assigned_to agar issue tidak muncul di dashboard teknisi
      'assigned_to': null,
      'assigned_at': null,
    }).eq('id', widget.issueId);
  }

  Future<void> initNotification() async {
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings =
        InitializationSettings(android: initSettingsAndroid);
    await notificationPlugin.initialize(settings: initSettings);
  }

  Future<void> showNotif(
      {int id = 0,
      required String title,
      required String body}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'issue_channel',
        'Issue tracker',
        channelDescription: 'Notifikasi status laporan,',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await notificationPlugin.show(id: id, title: title, body: body, notificationDetails: details);
  }

  Future<void> kirimNotifikasi() async {
    final issue = await supabase
        .from('issues')
        .select('title, reported_by, assigned_to')
        .eq('id', widget.issueId)
        .single();

    final judulIssue = issue['title'] ?? 'laporan';
    final karyawanId = issue['reported_by'] as String?;
    final teknisId = issue['assigned_to'] as String?;

    final admins =
        await supabase.from('users').select('id').eq('role', 'admin');

    final List<Map<String, dynamic>> notifList = [];

    if (karyawanId != null) {
      notifList.add({
        'user_id': karyawanId,
        'title': 'Laporan Tidak Selesai',
        'message': 'Laporan $judulIssue tidak selesai',
        'type': 'issue_pending',
        'is_read': false,
      });
    }

    if (teknisId != null) {
      notifList.add({
        'user_id': teknisId,
        'title': 'Tugas Tidak Selesai !',
        'message': 'Tugas $judulIssue tidak selesai',
        'type': 'issue_pending',
        'is_read': false,
      });
    }

    for (final admin in admins) {
      notifList.add({
        'user_id': admin['id'],
        'title': 'Laporan Tidak Selesai',
        'message': 'Laporan $judulIssue tidak selesai',
        'type': 'issue_pending',
        'is_read': false,
      });
    }

    if (notifList.isNotEmpty) {
      await supabase.from('notifications').insert(notifList);
    }
  }

  // No. 10: pickImage dengan error handling
  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );
      if (image != null) {
        setState(() => _imageFile = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal membuka ${source == ImageSource.camera ? "kamera" : "galeri"}: $e')),
        );
      }
    }
  }

  // No. 10: upload dengan error handling
  Future<void> uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih foto terlebih dahulu')),
      );
      return;
    }

    try {
      final fileName =
          '${widget.issueId}_reject_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';

      await supabase.storage.from('images').upload(
            path,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload foto berhasil')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: $e')),
        );
      }
    }
  }

  Future<void> updataeStatus() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase.from('users').update({
      'is_available': true,
    }).eq('id', userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 246, 246),
      appBar: AppBar(
        title: const Text("Tidak Selesai"),
        backgroundColor: Colors.grey[200],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Alasan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reject,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    "Masukkan alasan pekerjaan tidak selesai...",
                contentPadding: const EdgeInsets.all(14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Upload Foto Terkini",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),
              child: Column(
                children: [
                  _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _imageFile!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Text(
                          "Belum ada gambar",
                          style: TextStyle(color: Colors.grey),
                        ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300]),
                          onPressed: () =>
                              pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.black),
                          label: const Text("Camera",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300]),
                          onPressed: () =>
                              pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo,
                              color: Colors.black),
                          label: const Text("Gallery",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: uploadImage,
                      child: const Text("Upload Foto",
                          style: TextStyle(color: Colors.black)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (reject.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Alasan Tidak Boleh Kosong')));
                    return;
                  }
                  try {
                    await kirimNotifikasi();
                    await showNotif(
                        title: "Laporan Tidak Selesai",
                        body: "Tugas Tidak Selesai Dikerjakan");
                    await tidakSelesai();
                    await updataeStatus();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Laporan Berhasil')));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DashboardTeknisi()),
                    );
                  } catch (a) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ERROR $a')));
                  }
                },
                child: const Text(
                  "Re-assign",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}