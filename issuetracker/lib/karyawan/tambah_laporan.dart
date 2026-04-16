import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahLaporan extends StatefulWidget {
  const TambahLaporan({super.key});

  @override
  State<TambahLaporan> createState() => _TambahLaporanState();
}

class _TambahLaporanState extends State<TambahLaporan> {
  final supabase = Supabase.instance.client;

  final judul = TextEditingController();
  final lokasi = TextEditingController();
  final deskripsi = TextEditingController();

  String? selectKategori;
  String? selectPrioritas;
  File? _imageFile;

  // FIX 2: URL foto yang sudah diupload — disimpan dan dikirim saat submit
  String? _uploadedPhotoUrl;
  bool _isUploading = false;
  bool _isSubmitting = false;

  DateTime? _selectedDeadline;
  final ImagePicker picker = ImagePicker();

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;
    setState(() {
      _selectedDeadline = DateTime(date.year, date.month, date.day, 23, 59, 59);
    });
  }

  String _formatDeadline(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _uploadedPhotoUrl = null; // reset URL lama
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal buka kamera/galeri: $e')));
      }
    }
  }

  // FIX 2: Upload foto segera dan simpan URL
  Future<void> uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih foto terlebih dahulu')));
      return;
    }
    setState(() => _isUploading = true);
    try {
      final fileName = 'issue_${DateTime.now().microsecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';
      await supabase.storage
          .from('images')
          .upload(path, _imageFile!, fileOptions: const FileOptions(upsert: true));

      final publicUrl = supabase.storage.from('images').getPublicUrl(path);
      setState(() => _uploadedPhotoUrl = publicUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload foto berhasil ✓")));
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

  Future<void> _submitLaporan() async {
    if (selectKategori == null ||
        selectPrioritas == null ||
        judul.text.trim().isEmpty ||
        lokasi.text.trim().isEmpty ||
        deskripsi.text.trim().isEmpty ||
        _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Jika ada foto yang dipilih tapi belum diupload, upload dulu otomatis
      if (_imageFile != null && _uploadedPhotoUrl == null) {
        setState(() => _isUploading = true);
        final fileName = 'issue_${DateTime.now().microsecondsSinceEpoch}.jpg';
        final path = 'uploads/$fileName';
        await supabase.storage
            .from('images')
            .upload(path, _imageFile!, fileOptions: const FileOptions(upsert: true));
        _uploadedPhotoUrl = supabase.storage.from('images').getPublicUrl(path);
        setState(() => _isUploading = false);
      }

      await supabase.from('issues').insert({
        'title': judul.text.trim(),
        'description': deskripsi.text.trim(),
        'category': selectKategori,
        'priority': selectPrioritas,
        'location': lokasi.text.trim(),
        'status': 'Pending',
        'reported_by': supabase.auth.currentUser?.id,
        'deadline': _selectedDeadline!.toIso8601String(),
        if (_uploadedPhotoUrl != null) 'photo_url': _uploadedPhotoUrl,
      });

      if (mounted) {
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _kategoriButton(String label) {
    final isSelected = selectKategori == label;
    return GestureDetector(
      onTap: () => setState(() => selectKategori = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.blue,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _prioritasButton(String label, Color color) {
    final isSelected = selectPrioritas == label;
    return GestureDetector(
      onTap: () => setState(() => selectPrioritas = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600)),
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
        title: const Text("New Issue",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
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

            const Text("Lokasi", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(lokasi, "Lokasi"),
            const SizedBox(height: 20),

            const Text("Tenggat Waktu",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _selectedDeadline != null
                          ? Colors.blue
                          : Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        size: 18, color: Color.fromARGB(255, 21, 148, 252)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedDeadline == null
                            ? 'Pilih tenggat waktu tugas'
                            : _formatDeadline(_selectedDeadline!),
                        style: TextStyle(
                            color: _selectedDeadline != null
                                ? Colors.black
                                : Colors.grey),
                      ),
                    ),
                    if (_selectedDeadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedDeadline = null),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            const Text("Kategori",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: [
              _kategoriButton("IT"),
              _kategoriButton("Facilities"),
              _kategoriButton("Electrical"),
              _kategoriButton("Cleaning"),
              _kategoriButton("Security"),
              _kategoriButton("Plumbing"),
              _kategoriButton("Other"),
            ]),
            const SizedBox(height: 25),

            const Text("Prioritas",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: [
              _prioritasButton("Low", Colors.green),
              _prioritasButton("Medium", Colors.orange),
              _prioritasButton("High", Colors.red),
              _prioritasButton("Urgent", Colors.deepOrange),
            ]),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                  // Preview foto
                  if (_imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_imageFile!, height: 150),
                    )
                  else
                    const Text("Belum ada gambar"),

                  // Indikator sudah diupload
                  if (_uploadedPhotoUrl != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Foto terupload ✓',
                              style: TextStyle(
                                  color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 8),
                  // FIX 2: Tombol upload eksplisit, simpan URL
                  ElevatedButton(
                    onPressed: _isUploading ? null : uploadImage,
                    child: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Upload Foto"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSubmitting ? null : _submitLaporan,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Submit",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}