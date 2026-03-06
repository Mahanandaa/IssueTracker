import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:path/path.dart' show context;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:issuetracker/kasus/issuesModel.dart';
import '../kasus/issuesDatabase.dart';


class TidakSelesaiTeknisi extends StatefulWidget {
  const TidakSelesaiTeknisi({super.key});

  @override
  State<TidakSelesaiTeknisi> createState() => _TidakSelesaiTeknisiState();
  
}
  File? _imageFile;
    final issueService = IssueService();
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }
  
  void setState(Null Function() param0) {
  }
  

  Future uploadImage() async {
    if (_imageFile == null) return;
    final fileName = DateTime.now().microsecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';
    await Supabase.instance.client.storage
        .from('images')
        .upload(path, _imageFile!)
        .then((value) => ScaffoldMessenger.of(context as BuildContext)
            .showSnackBar(const SnackBar(content: Text("Upload foto berhasil"))));
  }
class _TidakSelesaiTeknisiState extends State<TidakSelesaiTeknisi> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tidak Selesai"),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          
           child: Padding(padding: EdgeInsetsGeometry.all(12),
            child: Column(
            children: [
              Text('Alasan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),),
              TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)
                  )
                ),
              ),
              Text('Upload Foto Terkini', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),),
              SizedBox(height: 12),
              
              _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, height: 150),
                        )
                      : const Text("Belum ada gambar"),
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
                      child: const Text("Upload Foto")),
              
              ElevatedButton(
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange
                ),
                onPressed: () {
                  
                   Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DashboardTeknisi(),
                        ),
                      );
                },
                child: Text(
                  'Re-assign', style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                  ),
                  
                ),
                
              )

            ],
            ),
           ),
        ),
      ),
    );
  }
}