import 'package:flutter/material.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
import 'package:issuetracker/kasus/issuesDatabase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
class EditLaporan extends StatefulWidget {
  final Map<String, dynamic> issue;
  const EditLaporan({super.key, required this.issue});

  @override
  State<EditLaporan> createState() => _EditLaporanState();
}

class _EditLaporanState extends State<EditLaporan> {
  final issueService = IssueService();
  var judul = TextEditingController();
  var lokasi = TextEditingController();
  var deskripsi = TextEditingController();

  String? selectKategori;
  String? selectPrioritas;

 @override
 void initState(){
  super.initState();
  _imageFile = (widget.issue['photoUrl']);
  selectPrioritas = (widget.issue['priority']);
  selectKategori = (widget.issue['category']);
  judul = TextEditingController(text: widget.issue['title']);
  lokasi = TextEditingController(text: widget.issue['location']);
  deskripsi = TextEditingController(text: widget.issue['description']);
 }

File? _imageFile;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future uploadImage() async {
    if (_imageFile == null) return;
    final fileName = DateTime.now().microsecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';
    await Supabase.instance.client.storage
        .from('images')
        .upload(path, _imageFile!)
        .then((value) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Upload foto berhasil"))));
  }
  Widget _inputField(TextEditingController controller, String hint) {
    return TextField(
      
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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
            const SizedBox(height: 25),
            const Text("Kategori",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                _prioritasButton("Low", Colors.green),
                _prioritasButton("Medium", Colors.orange),
                _prioritasButton("High", Colors.red),
                _prioritasButton("Urgent", Colors.red),
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
                  _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, height: 150),
                        ) : const Text("Belum ada gambar"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () =>
                              pickImage(ImageSource.camera),
                          child: const Text("Camera")),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: () =>
                              pickImage(ImageSource.gallery),
                          child: const Text("Gallery")),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: uploadImage,
                      child: const Text("Upload Foto"))
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                    try {
                    await issueService.updateIssue(
                      id: widget.issue['id'].toString(),
                      title: judul.text.trim(),
                      description: deskripsi.text.trim(),
                      category: selectKategori!,
                      priority: selectPrioritas!,
                      location: lokasi.text.trim(),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardKaryawan(),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text(
                  "Update",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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