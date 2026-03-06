import 'dart:io';
import 'progress_teknisi.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/teknisi/tidak_selesai_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/kasus/issuesDatabase.dart';
class SelesaiTeknis extends StatefulWidget {
  const SelesaiTeknis({super.key});

  @override
  State<SelesaiTeknis> createState() => _SelesaiTeknisState();
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
        .upload(path, _imageFile!);
       
  }
class _SelesaiTeknisState extends State<SelesaiTeknis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("Selesai"),
      
      ),
      body: SafeArea(
        
        child: Padding(
          padding: EdgeInsetsGeometry.all(12),
          child: Row(
            
            children: [
 Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
            ),
            child: Column(
              children: [
                _imageFile != null ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file( _imageFile!,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Text(
                        "Belum ada gambar",
                        style: TextStyle(
                            color: Colors.grey),
                      ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300]
                        ),
                        onPressed: () =>
                            pickImage(ImageSource.camera),
                        child: const Text("Camera", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300]
                        ),
                        onPressed: () =>
                            pickImage(ImageSource.gallery),
                        child: const Text("Gallery", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300]
                        ),
                    onPressed: uploadImage,

                    child: const Text("Upload Foto", style: TextStyle(color: Colors.black)),
                  ),
                )
              ],
            ),
          ),


          SizedBox(width: 10),
           Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
            ),
            child: Column(
              children: [
                _imageFile != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Text(
                        "Belum ada gambar",
                        style: TextStyle(
                            color: Colors.grey),
                      ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300]
                        ),
                        onPressed: () =>
                            pickImage(ImageSource.camera),
                        child: const Text("Camera", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300]
                        ),
                        onPressed: () =>
                            pickImage(ImageSource.gallery),
                        child: const Text("Gallery", style: TextStyle(color: Colors.black),),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300]
                        ),
                    onPressed: uploadImage,

                    child: const Text("Upload Foto", style: TextStyle(color: Colors.black)),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text('Sebelum', style: TextStyle(color: Colors.grey),
              ),
               Text('Sesudah', style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        
          SizedBox(height: 12),
          Text('Ringkasan Solusi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),),
            TextField(
               maxLines: 4,
            decoration: InputDecoration(
              
              hintText: "Ringkasan Solusi",
              border: OutlineInputBorder(
                
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
            SizedBox(height: 8),
            Text('Waktu Bekerja' , style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[600],
              ),
              child: Text('03: 21 : 32', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
            ),
            SizedBox(height: 8),
            Text('Spear Parts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Spear Parts yang digunakan..",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                )
              ),
            )
            ],
            
          ), 
          
        ),
      
      ),
    );
  }
}