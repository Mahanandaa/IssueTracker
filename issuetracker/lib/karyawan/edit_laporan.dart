import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditLaporan extends StatefulWidget {
  final Map<String, dynamic> issue;
  const EditLaporan({super.key, required this.issue});

  @override
  State<EditLaporan> createState() => _EditLaporanState();
}

class _EditLaporanState extends State<EditLaporan> {
  final supabase = Supabase.instance.client;

  late TextEditingController judul;
  late TextEditingController lokasi;
  late TextEditingController deskripsi;

  String? selectKategori;
  String? selectPrioritas;

  File? _imageFile;
  String? _existingPhotoUrl;
  bool _isUploading = false;
  bool _isSubmitting = false;

  // FIX 6: Deadline
  DateTime? _selectedDeadline;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _existingPhotoUrl = widget.issue['photo_url'] as String?;
    selectPrioritas = widget.issue['priority'];
    selectKategori = widget.issue['category'];
    judul = TextEditingController(text: widget.issue['title']);
    lokasi = TextEditingController(text: widget.issue['location']);
    deskripsi =
        TextEditingController(text: widget.issue['description']);

    // FIX 6: Parse deadline lama jika ada
    if (widget.issue['deadline'] != null) {
      try {
        _selectedDeadline =
            DateTime.parse(widget.issue['deadline'].toString());
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    judul.dispose();
    lokasi.dispose();
    deskripsi.dispose();
    super.dispose();
  }

  // FIX 6: Date-only picker untuk deadline
  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blue),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    setState(() {
      _selectedDeadline =
          DateTime(date.year, date.month, date.day, 23, 59, 59);
    });
  }

  String _formatDeadline(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await picker.pickImage(
          source: source, imageQuality: 80, maxWidth: 1080);
      if (image != null) setState(() => _imageFile = File(image.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Gagal membuka ${source == ImageSource.camera ? "kamera" : "galeri"}: $e')));
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _existingPhotoUrl;
    setState(() => _isUploading = true);
    try {
      final fileName =
          '${widget.issue['id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';
      await supabase.storage.from('images').upload(
            path,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );
      final publicUrl =
          supabase.storage.from('images').getPublicUrl(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload foto berhasil")));
      }
      return publicUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal upload foto: $e')));
      }
      return _existingPhotoUrl;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // FIX 6: Update langsung ke Supabase termasuk deadline
  Future<void> _updateLaporan() async {
    if (selectKategori == null || selectPrioritas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori dan prioritas')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final photoUrl = await _uploadImage();

      final Map<String, dynamic> updateData = {
        'title': judul.text.trim(),
        'description': deskripsi.text.trim(),
        'category': selectKategori,
        'priority': selectPrioritas,
        'location': lokasi.text.trim(),
        if (photoUrl != null) 'photo_url': photoUrl,
        // FIX 6: Update deadline (null jika dihapus)
        'deadline': _selectedDeadline?.toIso8601String(),
      };

      await supabase
          .from('issues')
          .update(updateData)
          .eq('id', widget.issue['id'].toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laporan berhasil diperbarui')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardKaryawan()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _inputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _kategoriButton(String label) {
    final isSelected = selectKategori == label;
    return GestureDetector(
      onTap: () => setState(() => selectKategori = label),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _prioritasButton(String label, Color color) {
    final isSelected = selectPrioritas == label;
    return GestureDetector(
      onTap: () => setState(() => selectPrioritas = label),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Update Issue",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("Judul Masalah",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(judul, "Masukan judul masalah"),
            const SizedBox(height: 20),

            const Text("Lokasi",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(lokasi, "Lokasi"),
            const SizedBox(height: 20),

            // FIX 6: Deadline picker
            const Text("Tenggat Waktu (Tanggal)",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedDeadline != null
                        ? Colors.blue
                        : Colors.grey.shade400,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        size: 18,
                        color: Color.fromARGB(255, 21, 148, 252)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedDeadline != null
                            ? _formatDeadline(_selectedDeadline!)
                            : 'Pilih tanggal tenggat waktu',
                        style: TextStyle(
                          color: _selectedDeadline != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                    if (_selectedDeadline != null)
                      GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDeadline = null),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            const Text("Kategori",
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _kategoriButton("IT"),
                _kategoriButton("Facilities"),
                _kategoriButton("Electrical"),
                _kategoriButton("Cleaning"),
                _kategoriButton("Security"),
                _kategoriButton("Plumbing"),
                _kategoriButton("Other"),
              ],
            ),
            const SizedBox(height: 25),

            const Text("Prioritas",
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _prioritasButton("Low", Colors.green),
                _prioritasButton("Medium", Colors.orange),
                _prioritasButton("High", Colors.red),
                _prioritasButton("Urgent", Colors.deepOrange),
              ],
            ),
            const SizedBox(height: 25),

            const Text("Deskripsi",
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: deskripsi,
              maxLength: 225,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tuliskan deskripsi masalah",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 25),

            const Text("Tambah Foto (Opsional)",
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (_imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_imageFile!, height: 150),
                    )
                  else if (_existingPhotoUrl != null &&
                      _existingPhotoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _existingPhotoUrl!,
                        height: 150,
                        errorBuilder: (_, __, ___) =>
                            const Text("Gagal memuat foto"),
                      ),
                    )
                  else
                    const Text("Belum ada gambar"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () => pickImage(ImageSource.camera),
                          child: const Text("Camera")),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: () =>
                              pickImage(ImageSource.gallery),
                          child: const Text("Gallery")),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    (_isUploading || _isSubmitting) ? null : _updateLaporan,
                child: (_isUploading || _isSubmitting)
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text(
                        "Update",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}