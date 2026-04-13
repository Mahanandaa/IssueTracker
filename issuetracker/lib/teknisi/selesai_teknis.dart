import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// FIX 5: Instance notifikasi lokal — init di main.dart atau di sini
final FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();

class SelesaiTeknis extends StatefulWidget {
  final String issueId;

  // FIX 4: Terima URL foto sebelum dari ProgressTeknisi
  final String? photoBeforeUrl;

  const SelesaiTeknis({
    super.key,
    required this.issueId,
    this.photoBeforeUrl,
  });

  @override
  State<SelesaiTeknis> createState() => _SelesaiTeknisState();
}

class _SelesaiTeknisState extends State<SelesaiTeknis> {
  // FIX 4: Foto sebelum dari progress, foto sesudah diambil di halaman ini
  XFile? imageAfter;
  String? _uploadedAfterUrl;
  bool _isUploading = false;

  final ImagePicker picker = ImagePicker();
  final solusiController = TextEditingController();
  final sparepartController = TextEditingController();

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initNotification();
  }

  @override
  void dispose() {
    solusiController.dispose();
    sparepartController.dispose();
    super.dispose();
  }

  // FIX 5: Inisialisasi flutter_local_notifications
  Future<void> _initNotification() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
await notificationPlugin.initialize(
  settings: initSettings,
);
  }

  // FIX 5: Tampilkan notifikasi pop-up lokal
  Future<void> _showLocalNotif({
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
        showWhen: true,
      ),
    );
await notificationPlugin.show(
  id: id,
  title: title,
  body: body,
  notificationDetails: details,
);  }

  Future<void> _updateStatus() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase
        .from('users')
        .update({'is_available': true}).eq('id', userId);
  }

  Future<void> _selesai() async {
    await supabase.from('issues').update({
      'status': 'Resolved',
      'resolved_at': DateTime.now().toIso8601String(),
      // FIX 4: Simpan ringkasan solusi ke resolution_notes
      'resolution_notes': solusiController.text.trim(),
      // FIX 4: Simpan URL foto sesudah ke completion_photo_url
      if (_uploadedAfterUrl != null)
        'completion_photo_url': _uploadedAfterUrl,
    }).eq('id', widget.issueId);
  }

  // FIX 5: Kirim notifikasi ke database (in-app) + pop-up lokal
  Future<void> _kirimNotifikasi() async {
    final issue = await supabase
        .from('issues')
        .select('title, reported_by, assigned_to')
        .eq('id', widget.issueId)
        .single();

    final judulIssue = issue['title'] ?? 'Laporan';
    final karyawanId = issue['reported_by'] as String?;
    final teknisiId = issue['assigned_to'] as String?;

    final admins =
        await supabase.from('users').select('id').eq('role', 'admin');

    final List<Map<String, dynamic>> notifList = [];

    if (karyawanId != null) {
      notifList.add({
        'user_id': karyawanId,
        'title': 'Laporan Selesai',
        'message': 'Laporan "$judulIssue" telah selesai ditangani.',
        'type': 'issue_resolved',
        'is_read': false,
      });
    }

    if (teknisiId != null) {
      notifList.add({
        'user_id': teknisiId,
        'title': 'Tugas Selesai',
        'message': 'Kamu telah menyelesaikan laporan "$judulIssue".',
        'type': 'task_completed',
        'is_read': false,
      });
    }

    for (final admin in admins) {
      notifList.add({
        'user_id': admin['id'],
        'title': 'Laporan Diselesaikan',
        'message':
            'Laporan "$judulIssue" telah diselesaikan oleh teknisi.',
        'type': 'issue_resolved',
        'is_read': false,
      });
    }

    if (notifList.isNotEmpty) {
      await supabase.from('notifications').insert(notifList);
    }
  }

  Future<void> pickImageAfter(ImageSource source) async {
    try {
      final image = await picker.pickImage(
          source: source, imageQuality: 80, maxWidth: 1080);
      if (image != null) setState(() => imageAfter = image);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal buka galeri/kamera: $e')));
      }
    }
  }

  // FIX 4: Upload foto sesudah dan simpan URL ke issues.completion_photo_url
  Future<void> _uploadFotoSesudah() async {
    if (imageAfter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih foto sesudah terlebih dahulu')));
      return;
    }
    setState(() => _isUploading = true);
    try {
      final fileName =
          '${widget.issueId}_after_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';

      await supabase.storage.from('images').upload(
            path,
            File(imageAfter!.path),
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl =
          supabase.storage.from('images').getPublicUrl(path);

      setState(() => _uploadedAfterUrl = publicUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto sesudah berhasil diupload')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Widget _buildFotoSebelum() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            const Text("Sebelum",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 10),
            // FIX 4: Tampilkan foto sebelum dari ProgressTeknisi
            widget.photoBeforeUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.photoBeforeUrl!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Text('Gagal memuat foto'),
                    ),
                  )
                : Container(
                    height: 140,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Belum ada foto sebelum",
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoSesudah() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            const Text("Sesudah",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 10),
            imageAfter != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(imageAfter!.path),
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover),
                  )
                : Container(
                    height: 140,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Belum ada gambar",
                        style: TextStyle(color: Colors.black54)),
                  ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        pickImageAfter(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: const Text("Camera"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        pickImageAfter(ImageSource.gallery),
                    icon: const Icon(Icons.image, size: 16),
                    label: const Text("Gallery"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadFotoSesudah,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700]),
                child: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Upload',
                        style: TextStyle(color: Colors.white)),
              ),
            ),
            if (_uploadedAfterUrl != null)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text('Terupload',
                        style: TextStyle(
                            color: Colors.green, fontSize: 11)),
                  ],
                ),
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
            // FIX 4: Dua panel foto (sebelum dari props, sesudah upload di sini)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFotoSebelum(),
                const SizedBox(width: 12),
                _buildFotoSesudah(),
              ],
            ),

            const SizedBox(height: 25),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Ringkasan Solusi",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: solusiController,
              maxLines: 4,
              decoration:
                  inputStyle("Jelaskan solusi yang dilakukan..."),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Spare Parts",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: sparepartController,
              maxLines: 3,
              decoration:
                  inputStyle("Spare parts yang digunakan..."),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _updateStatus();
                    await _selesai();
                    await _kirimNotifikasi();

                    await _showLocalNotif(
                      title: 'Tugas Selesai',
                      body: 'Laporan berhasil diselesaikan!',
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Pekerjaan berhasil diselesaikan")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DashboardTeknisi()),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                child: const Text(
                  "Selesaikan Pekerjaan",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}