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

  Future<void> _selesai() async {
    await supabase.from('issues').update({
      'status': 'Resolved',
      'resolved_at': DateTime.now().toIso8601String(),
      'resolution_notes': solusiController.text.trim(),
      if (_uploadedAfterUrl != null)
        'completion_photo_url': _uploadedAfterUrl,
    }).eq('id', widget.issueId);

    if (sparepartController.text.trim().isNotEmpty) {
      await supabase.from('spare_parts').insert({
        'issue_id': widget.issueId,
        'part_name': sparepartController.text.trim(),
        'quantity': 1,
      });
    }
  }

  Future<void> pickImageAfter(ImageSource source) async {
    final image =
        await picker.pickImage(source: source, imageQuality: 80);

    if (image != null) {
      setState(() => imageAfter = image);
    }
  }

  Future<void> _uploadFotoSesudah() async {
    if (imageAfter == null) return;

    setState(() => _isUploading = true);
    try {
      final fileName =
          '${widget.issueId}_after_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';

      // Pakai upload (bukan update) dengan upsert: true
      await supabase.storage.from('images').upload(
            path,
            File(imageAfter!.path),
            fileOptions: const FileOptions(upsert: true),
          );

      final url = supabase.storage.from('images').getPublicUrl(path);

      setState(() => _uploadedAfterUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal upload foto: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
                    ? Image.network(
                        _photoBeforeUrl!,
                        height: 140,
                        fit: BoxFit.cover,
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
                ? Image.file(
                    File(imageAfter!.path),
                    height: 140,
                    fit: BoxFit.cover,
                  )
                : const Text("Belum ada gambar"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        pickImageAfter(ImageSource.camera),
                    child: const Icon(Icons.camera_alt_outlined),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        pickImageAfter(ImageSource.gallery),
                    child: const Icon(Icons.image),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
            Text(
              'Ringkasan Solusi', 
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              
            ),
            SizedBox(height: 20),
            TextField(
              controller: solusiController,
              maxLines: 3,
              decoration: inputStyle("Ringkasan solusi"),
            ),
              const SizedBox(height: 20),
            Text(
              'Spare parts', 
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              
            ),
            SizedBox(height: 20),
            TextField(
              controller: sparepartController,
              maxLines: 2,
              decoration: inputStyle("Spare parts"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (solusiController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ringkasan solusi wajib diisi')),
                    );
                    return;
                  }

                  // Upload foto DULU agar URL sudah tersedia saat _selesai()
                  await _uploadFotoSesudah();
                  await _updateStatus();
                  await _selesai();
                  await _showLocalNotif(
                    title: 'Selesai',
                    body: 'Berhasil diselesaikan',
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
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Selesaikan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}