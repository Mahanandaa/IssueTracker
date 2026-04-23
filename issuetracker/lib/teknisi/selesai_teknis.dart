import 'dart:io';
import 'package:flutter/foundation.dart';
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
  XFile? imageAfter;
  String? _uploadedAfterUrl;
  bool _isUploading = false;

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

  Future<void> _fetchPhotoBefore() async {
    final data = await supabase
        .from('issues')
        .select('photo_url')
        .eq('id', widget.issueId)
        .maybeSingle();

    setState(() {
      _photoBeforeUrl = data?['photo_url'];
      _isLoadingBefore = false;
    });
  }

  Future<void> _initNotification() async {
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: initSettingsAndroid);
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
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    await notificationPlugin.show(
        id: id, title: title, body: body, notificationDetails: details);
  }

  Future<void> _updateStatus() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase
        .from('users')
        .update({'is_available': true}).eq('id', userId);
  }

  Future<void> _kirimNotifikasi(String? assignedTo) async {
    try {
      final issue = await supabase
          .from('issues')
          .select('title, reported_by')
          .eq('id', widget.issueId)
          .single();

      final judulIssue = issue['title'] ?? 'Laporan';
      final karyawanId = issue['reported_by'] as String?;

      final admins =
          await supabase.from('users').select('id').eq('role', 'admin');

      final List<Map<String, dynamic>> notifList = [];

      if (karyawanId != null) {
        notifList.add({
          'user_id': karyawanId,
          'title': 'Laporan Selesai!',
          'message': 'Laporan "$judulIssue" telah selesai ditangani.',
          'type': 'issue_resolved',
          'is_read': false,
        });
      }

      if (assignedTo != null) {
        notifList.add({
          'user_id': assignedTo,
          'title': 'Tugas Selesai!',
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
    } catch (e) {
      debugPrint('kirimNotifikasi error: $e');
    }
  }

  Future<String?> _uploadFotoSesudah() async {
    if (imageAfter == null) return null;

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

      final url = supabase.storage.from('images').getPublicUrl(path);
      setState(() => _uploadedAfterUrl = url);
      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal upload foto: $e')));
      }
      return null;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _selesai(String? photoUrl) async {
    await supabase.from('issues').update({
      'status': 'Resolved',
      'resolved_at': DateTime.now().toIso8601String(),
      if (photoUrl != null) 'completion_photo_url': photoUrl,
    }).eq('id', widget.issueId);

    if (sparepartController.text.trim().isNotEmpty) {
      await supabase.from('spare_parts').insert({
        'issue_id': widget.issueId,
        'part_name': sparepartController.text.trim(),
       
      });
    }
  }

  Future<void> pickImageAfter(ImageSource source) async {
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setState(() => imageAfter = image);
    }
  }

  Widget card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: child,
    );
  }

  Widget fotoSebelum() {
    return Expanded(
      child: card(
        child: Column(
          children: [
            const Text("Sebelum",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _isLoadingBefore
                ? const CircularProgressIndicator()
                : _photoBeforeUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _photoBeforeUrl!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Text("Tidak ada foto"),
          ],
        ),
      ),
    );
  }

  Widget fotoSesudah() {
    return Expanded(
      child: card(
        child: Column(
          children: [
            const Text("Sesudah",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            imageAfter != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(imageAfter!.path),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Text("Belum ada gambar"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickImageAfter(ImageSource.camera),
                    child: const Icon(Icons.camera_alt_outlined),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => pickImageAfter(ImageSource.gallery),
                    child: const Icon(Icons.image),
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
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Selesaikan Pekerjaan"),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                fotoSebelum(),
                const SizedBox(width: 10),
                fotoSesudah(),
              ],
            ),
            const SizedBox(height: 20),
           
                 const SizedBox(height: 20),
            const Text(
              'Spare Parts',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: sparepartController,
              maxLines: 2,
              decoration: inputStyle("Spare parts yang digunakan"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading
                    ? null
                    : () async {
                       
                        final issueData = await supabase
                            .from('issues')
                            .select('assigned_to')
                            .eq('id', widget.issueId)
                            .maybeSingle();
                        final assignedTo =
                            issueData?['assigned_to'] as String?;

                        final photoUrl = await _uploadFotoSesudah();

                        await _selesai(photoUrl);

                        await _updateStatus();

                        await _kirimNotifikasi(assignedTo);

                        await _showLocalNotif(
                          title: 'Tugas Selesai!',
                          body: 'Pekerjaan berhasil diselesaikan',
                        );

                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardTeknisi(),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Selesaikan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}