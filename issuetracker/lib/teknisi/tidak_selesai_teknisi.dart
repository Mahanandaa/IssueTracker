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
  State<TidakSelesaiTeknisi> createState() =>
      _TidakSelesaiTeknisiState();
}

class _TidakSelesaiTeknisiState extends State<TidakSelesaiTeknisi> {
  File? _imageFile;
  String? _uploadedPhotoUrl;
  bool _isUploading = false;

  final ImagePicker picker = ImagePicker();
  final TextEditingController reject = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    reject.dispose();
    super.dispose();
  }

  // ✅ FIX UPDATE ISSUE
  Future<void> tidakSelesai() async {
    await supabase.from('issues').update({
      'status': 'Pending',
      'resolution_notes': reject.text.trim(),
      if (_uploadedPhotoUrl != null)
        'completion_photo_url': _uploadedPhotoUrl,
      'assigned_at': null,
    }).eq('id', widget.issueId);
  }

  Future<void> showNotif({
    int id = 0,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'issue_channel',
        'Issue tracker',
        channelDescription: 'Notifikasi status laporan',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await notificationPlugin.show(
        id: id, title: title, body: body, notificationDetails: details);
  }

  // ✅ FIX NOTIF ENUM
  Future<void> kirimNotifikasi() async {
    final issue = await supabase
        .from('issues')
        .select('title, reported_by')
        .eq('id', widget.issueId)
        .single();

    final judulIssue = issue['title'] ?? 'laporan';
    final karyawanId = issue['reported_by'] as String?;

    final admins =
        await supabase.from('users').select('id').eq('role', 'admin');

    final List<Map<String, dynamic>> notifList = [];

    if (karyawanId != null) {
      notifList.add({
        'user_id': karyawanId,
        'title': 'Laporan Tidak Selesai',
        'message': 'Laporan $judulIssue tidak selesai',
        'type': 'issue_resolved', // ✅ ENUM VALID
        'is_read': false,
      });
    }

    for (final admin in admins) {
      notifList.add({
        'user_id': admin['id'],
        'title': 'Laporan Tidak Selesai',
        'message': 'Laporan $judulIssue tidak selesai',
        'type': 'issue_resolved',
        'is_read': false,
      });
    }

    if (notifList.isNotEmpty) {
      await supabase.from('notifications').insert(notifList);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final image = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _uploadedPhotoUrl = null;
      });
    }
  }

  Future<void> uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih foto dulu')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final fileName =
          '${widget.issueId}_reject_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';

      await supabase.storage.from('images').upload(
            path,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl =
          supabase.storage.from('images').getPublicUrl(path);

      setState(() => _uploadedPhotoUrl = publicUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload berhasil ✓')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error upload: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
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
            const Text("Alasan",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            TextField(
              controller: reject,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Masukkan alasan...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 25),

            const Text("Upload Foto",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            _imageFile != null
                ? Image.file(_imageFile!, height: 150)
                : const Text("Belum ada gambar"),

            Row(
              children: [
                ElevatedButton(
                    onPressed: () => pickImage(ImageSource.camera),
                    child: const Text("Camera")),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () => pickImage(ImageSource.gallery),
                    child: const Text("Gallery")),
              ],
            ),

            ElevatedButton(
                onPressed: _isUploading ? null : uploadImage,
                child: const Text("Upload")),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                if (reject.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alasan wajib diisi')));
                  return;
                }

                await kirimNotifikasi();
                await showNotif(
                    title: "Laporan Tidak Selesai",
                    body: "Tugas tidak selesai");
                await tidakSelesai();
                await updataeStatus();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DashboardTeknisi()),
                );
              },
              child: const Text("Re-assign"),
            )
          ],
        ),
      ),
    );
  }
}