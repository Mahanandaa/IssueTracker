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

  Widget card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: child,
    );
  }

  Future<String?> uploadImageDanAmbilUrl() async {
    if (_imageFile == null) return null;

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

      final publicUrl = supabase.storage.from('images').getPublicUrl(path);
      setState(() => _uploadedPhotoUrl = publicUrl);
      return publicUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error upload: $e')),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> tidakSelesai(String? photoUrl) async {
    
    await supabase.from('issues').update({
      'status': 'Escalated',
      'resolution_notes': reject.text.trim(),
      if (photoUrl != null) 'completion_photo_url': photoUrl,
      'assigned_at': null,
      'assigned_to': null,
      'started_at': null,
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
        'type': 'issue_resolved',
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

  Future<void> updateStatus() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('users').update({
      'is_available': true,
    }).eq('id', userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text("Tidak Selesai"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Alasan",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reject,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Masukkan alasan...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Upload Foto",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 10),

                  _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _imageFile!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          height: 150,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text("Belum ada gambar"),
                        ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.black),
                          label: const Text("Camera",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image,
                              color: Colors.black),
                          label: const Text("Gallery",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading
                    ? null
                    : () async {
                        if (reject.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Alasan wajib diisi')),
                          );
                          return;
                        }

                        final photoUrl = await uploadImageDanAmbilUrl();

                        await tidakSelesai(photoUrl);

                        await kirimNotifikasi();
                        await showNotif(
                          title: "Laporan Tidak Selesai",
                          body: "Tugas tidak selesai",
                        );
                        await updateStatus();

                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DashboardTeknisi()),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Re-Assign",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}