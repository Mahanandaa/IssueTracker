import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Warna utama app
const kPrimary = Color(0xFF3B6FF0);
const kPrimaryLight = Color(0xFFEEF2FF);
const kSurface = Color(0xFFF8F9FC);
const kBorder = Color(0xFFE2E8F0);
const kText = Color(0xFF1A202C);
const kSubtext = Color(0xFF718096);

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

  String? _uploadedPhotoUrl;
  bool _isUploading = false;
  bool _isSubmitting = false;

  // Error states untuk validasi
  String? _judulError;
  String? _lokasiError;
  String? _kategoriError;
  String? _prioritasError;
  String? _deskripsiError;
  String? _deadlineError;

  DateTime? _selectedDeadline;
  final ImagePicker picker = ImagePicker();

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: kPrimary),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    setState(() {
      _selectedDeadline = DateTime(date.year, date.month, date.day, 23, 59, 59);
      _deadlineError = null;
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
          _uploadedPhotoUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Gagal buka kamera/galeri: $e');
      }
    }
  }

  Future<void> uploadImage() async {
    if (_imageFile == null) {
      _showSnack('Pilih foto terlebih dahulu');
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
      if (mounted) _showSnack('Upload foto berhasil ✓');
    } catch (e) {
      if (mounted) _showSnack('Gagal upload: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _judulError = judul.text.trim().isEmpty ? 'Judul masalah wajib diisi' : null;
      _lokasiError = lokasi.text.trim().isEmpty ? 'Lokasi wajib diisi' : null;
      _kategoriError = selectKategori == null ? 'Pilih salah satu kategori' : null;
      _prioritasError = selectPrioritas == null ? 'Pilih tingkat prioritas' : null;
      _deskripsiError = deskripsi.text.trim().isEmpty ? 'Deskripsi wajib diisi' : null;
      _deadlineError = _selectedDeadline == null ? 'Tenggat waktu wajib dipilih' : null;
    });
    if (_judulError != null || _lokasiError != null || _kategoriError != null ||
        _prioritasError != null || _deskripsiError != null || _deadlineError != null) {
      valid = false;
    }
    return valid;
  }

  Future<void> _submitLaporan() async {
    if (!_validate()) {
      _showSnack('Harap lengkapi semua field yang wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
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
      if (mounted) _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _label(String text, {bool required = true}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: kText,
        ),
        children: required
            ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
            : [],
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: kText, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kSubtext, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red.shade300 : kBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 13, color: Colors.red),
              const SizedBox(width: 4),
              Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _kategoriButton(String label) {
    final isSelected = selectKategori == label;
    return GestureDetector(
      onTap: () => setState(() {
        selectKategori = label;
        _kategoriError = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? kPrimary : kBorder),
          boxShadow: isSelected
              ? [BoxShadow(color: kPrimary.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kSubtext,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _prioritasButton(String label, Color color) {
    final isSelected = selectPrioritas == label;
    return GestureDetector(
      onTap: () => setState(() {
        selectPrioritas = label;
        _prioritasError = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : kBorder),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kSubtext,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _errorNote(String msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 13, color: Colors.red),
          const SizedBox(width: 4),
          Text(msg, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Laporan Baru",
          style: TextStyle(fontWeight: FontWeight.w700, color: kText, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: kText),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [

            // — Judul —
            _label("Judul Masalah"),
            const SizedBox(height: 8),
            _inputField(judul, "Masukan judul masalah", errorText: _judulError),
            const SizedBox(height: 20),

            // — Lokasi —
            _label("Lokasi"),
            const SizedBox(height: 8),
            _inputField(lokasi, "Contoh: Gedung A, Lantai 2", errorText: _lokasiError),
            const SizedBox(height: 20),

            // — Tenggat Waktu —
            _label("Tenggat Waktu"),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _deadlineError != null
                        ? Colors.red.shade300
                        : _selectedDeadline != null
                            ? kPrimary
                            : kBorder,
                    width: _selectedDeadline != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: _selectedDeadline != null ? kPrimary : kSubtext,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedDeadline == null
                            ? 'Pilih tenggat waktu'
                            : _formatDeadline(_selectedDeadline!),
                        style: TextStyle(
                          color: _selectedDeadline != null ? kText : kSubtext,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (_selectedDeadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedDeadline = null),
                        child: const Icon(Icons.close, size: 16, color: kSubtext),
                      ),
                  ],
                ),
              ),
            ),
            if (_deadlineError != null) _errorNote(_deadlineError!),
            const SizedBox(height: 24),

            // — Kategori —
            _label("Kategori"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
            if (_kategoriError != null) _errorNote(_kategoriError!),
            const SizedBox(height: 24),

            // — Prioritas —
            _label("Prioritas"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _prioritasButton("Low", const Color(0xFF38A169)),
                _prioritasButton("Medium", const Color(0xFFD69E2E)),
                _prioritasButton("High", const Color(0xFFE53E3E)),
                _prioritasButton("Urgent", const Color(0xFFC05621)),
              ],
            ),
            if (_prioritasError != null) _errorNote(_prioritasError!),
            const SizedBox(height: 24),

            // — Deskripsi —
            _label("Deskripsi"),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: deskripsi,
                  maxLength: 225,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: kText, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Jelaskan masalah secara detail...",
                    hintStyle: const TextStyle(color: kSubtext, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kBorder)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _deskripsiError != null ? Colors.red.shade300 : kBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kPrimary, width: 1.5),
                    ),
                  ),
                ),
                if (_deskripsiError != null) _errorNote(_deskripsiError!),
              ],
            ),
            const SizedBox(height: 24),

            // — Foto (opsional) —
            Row(
              children: [
                const Text(
                  "Tambah Foto",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: kText),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Opsional",
                    style: TextStyle(color: kPrimary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: [
                  if (_imageFile != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_imageFile!, height: 160, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 10),
                    if (_uploadedPhotoUrl != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, color: Color(0xFF38A169), size: 16),
                          SizedBox(width: 4),
                          Text('Foto terupload ✓',
                              style: TextStyle(color: Color(0xFF38A169), fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                  ] else
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kPrimaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.image_outlined, color: kPrimary, size: 28),
                        ),
                        const SizedBox(height: 8),
                        const Text("Belum ada foto dipilih",
                            style: TextStyle(color: kSubtext, fontSize: 13)),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined, size: 16),
                          label: const Text("Kamera"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimary,
                            side: const BorderSide(color: kPrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined, size: 16),
                          label: const Text("Galeri"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimary,
                            side: const BorderSide(color: kPrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_imageFile != null && _uploadedPhotoUrl == null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : uploadImage,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.cloud_upload_outlined, size: 16),
                        label: Text(_isUploading ? "Mengupload..." : "Upload Foto"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // — Submit —
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  shadowColor: kPrimary.withOpacity(0.4),
                ),
                onPressed: _isSubmitting ? null : _submitLaporan,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        "Kirim Laporan",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}