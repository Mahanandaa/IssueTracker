import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  // Foto sesudah dipilih teknisi
  XFile? imageAfter;
  String? _uploadedAfterUrl;
  bool _isUploading = false;

  // Foto sebelum diambil dari DB (photo_url yang diupload karyawan)
  String? _photoBeforeUrl;
  bool _isLoadingBefore = true;

  final ImagePicker picker = ImagePicker();
  final solusiController = TextEditingController();
  final sparepartController = TextEditingController();

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initNotification();
    _fetchPhotoBefore();
  }

  @override
  void dispose() {
    solusiController.dispose();
    sparepartController.dispose();
    super.dispose();
  }

  // Ambil foto sebelum (photo_url) dari tabel issues
  Future<void> _fetchPhotoBefore() async {
    try {
      final data = await supabase
          .from('issues')
          .select('photo_url')
          .eq('id', widget.issueId)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _photoBeforeUrl = data?['photo_url'] as String?;
          _isLoadingBefore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingBefore = false);
    }
  }

  Future<void> _initNotification() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await notificationPlugin.initialize(settings: initSettings);
  }

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
    );
  }

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
      'resolution_notes': solusiController.text.trim(),
      if (_uploadedAfterUrl != null)
        'completion_photo_url': _uploadedAfterUrl,
    }).eq('id', widget.issueId);
  }

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
        'message': 'Laporan "$judulIssue" telah diselesaikan oleh teknisi.',
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
            const SnackBar(content: Text('Foto sesudah berhasil diupload ✓')));
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
            if (_isLoadingBefore)
              const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_photoBeforeUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _photoBeforeUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Gagal memuat foto",
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center),
                  ),
                ),
              )
            else
              Container(
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
                    onPressed: () => pickImageAfter(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: const Text("Camera"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImageAfter(ImageSource.gallery),
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
                    Icon(Icons.check_circle, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text('Terupload ✓',
                        style: TextStyle(color: Colors.green, fontSize: 11)),
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
            // Dua panel foto: sebelum (dari DB) dan sesudah (upload teknisi)
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
              decoration: inputStyle("Jelaskan solusi yang dilakukan..."),
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
              decoration: inputStyle("Spare parts yang digunakan..."),
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
                            content: Text("Pekerjaan berhasil diselesaikan")),
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