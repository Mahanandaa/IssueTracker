import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Plugin notifikasi lokal — dideklarasikan di sini agar bisa dipakai di seluruh file
final FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();

class SelesaiTeknis extends StatefulWidget {
  final String issueId;

  const SelesaiTeknis({
    super.key,
    required this.issueId,
  });

  @override
  State<SelesaiTeknis> createState() => _SelesaiTeknisState();
}

class _SelesaiTeknisState extends State<SelesaiTeknis> {
  XFile? imageBefore;
  XFile? imageAfter;

  final ImagePicker picker = ImagePicker();
  final solusiController = TextEditingController();
  final sparepartController = TextEditingController();

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    initNotification();
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

  // Update status issue menjadi Resolved
  Future<void> selesai() async {
    await supabase.from('issues').update({
      'status': 'Resolved',
      'resolved_at': DateTime.now().toIso8601String(),
    }).eq('id', widget.issueId);
  }

  // Simpan notifikasi ke tabel notifications untuk teknisi, admin, dan karyawan
  Future<void> kirimNotifikasi() async {
    // Ambil data issue: judul, siapa pelapor, siapa teknisi
    final issue = await supabase
        .from('issues')
        .select('title, reported_by, assigned_to')
        .eq('id', widget.issueId)
        .single();

    final judulIssue = issue['title'] ?? 'Laporan';
    final karyawanId = issue['reported_by'] as String?;
    final teknisiId = issue['assigned_to'] as String?;

    // Ambil semua admin
    final admins = await supabase
        .from('users')
        .select('id')
        .eq('role', 'admin');

    final List<Map<String, dynamic>> notifList = [];

    // Notifikasi untuk karyawan pelapor
    if (karyawanId != null) {
      notifList.add({
        'user_id': karyawanId,
        'title': 'Laporan Selesai',
        'message': 'Laporan "$judulIssue" telah selesai ditangani.',
        'type': 'issue_resolved',
        'is_read': false,
      });
    }

    // Notifikasi untuk teknisi
    if (teknisiId != null) {
      notifList.add({
        'user_id': teknisiId,
        'title': 'Tugas Selesai',
        'message': 'Kamu telah menyelesaikan laporan "$judulIssue".',
        'type': 'task_completed',
        'is_read': false,
      });
    }

    // Notifikasi untuk semua admin
    for (final admin in admins) {
      notifList.add({
        'user_id': admin['id'],
        'title': 'Laporan Diselesaikan',
        'message': 'Laporan "$judulIssue" telah diselesaikan oleh teknisi.',
        'type': 'issue_resolved',
        'is_read': false,
      });
    }

    if (notifList.isNotEmpty) {
      await supabase.from('notifications').insert(notifList);
    }
  }

  Future<void> pickImage(ImageSource source, bool before) async {
    final image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        if (before) {
          imageBefore = image;
        } else {
          imageAfter = image;
        }
      });
    }
  }

  Widget buildImageCard(String title, XFile? image, bool isBefore) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100,
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),

            // IMAGE PREVIEW
            image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(image.path),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 140,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Belum ada gambar",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera, isBefore),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery, isBefore),
                    icon: const Icon(Icons.image),
                    label: const Text("Gallery"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Selesaikan Pekerjaan"),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                buildImageCard("Sebelum", imageBefore, true),
                const SizedBox(width: 12),
                buildImageCard("Sesudah", imageAfter, false),
              ],
            ),

            const SizedBox(height: 25),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ringkasan Solusi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: solusiController,
              maxLines: 4,
              decoration: inputStyle("Jelaskan solusi yang dilakukan..."),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Spare Parts",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: sparepartController,
              maxLines: 3,
              decoration: inputStyle("Spare parts yang digunakan..."),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                   await selesai();
                   await kirimNotifikasi();
                  await showNotif(
                      title: 'Tugas Selesai',
                      body: 'Laporan berhasil diselesaikan!',
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Pekerjaan berhasil diselesaikan"),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardTeknisi(),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  "Selesaikan Pekerjaan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
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