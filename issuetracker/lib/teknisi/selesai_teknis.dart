import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

Future<void>selesai() async{
  await Supabase.instance.client.from('issues').update({
    'status' : 'Resolved',
  })
  .eq('id', widget.issueId);
}

  XFile? imageBefore;
  XFile? imageAfter;

  final ImagePicker picker = ImagePicker();

  final solusiController = TextEditingController();
  final sparepartController = TextEditingController();

  Future<void> pickImage(ImageSource source, bool before) async {

    final image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        if (before) {
          imageBefore = image;
        } else {
          imageAfter = image;
        }
      });
    }
  }

  Future<void> uploadImage(XFile? file) async {
    if (file == null) return;
    Uint8List bytes = await file.readAsBytes();
    final fileName = DateTime.now().microsecondsSinceEpoch.toString();
    final path = 'uploads/$fileName.jpg';
    await Supabase.instance.client.storage
        .from('images')
        .uploadBinary(path, bytes);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Selesai Pekerjaan"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                Expanded(
                  child: Container(

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6)
                      ],
                    ),

                    child: Column(
                      children: [

                        const Text(
                          "Sebelum",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 10),

                        imageBefore != null
                            ? Image.network(
                                imageBefore!.path,
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
                                    pickImage(ImageSource.camera, true),
                                child: const Text("Camera"),
                              ),
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    pickImage(ImageSource.gallery, true),
                                child: const Text("Gallery"),
                              ),
                            ),
                          ],
                        )

                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Container(

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6)
                      ],
                    ),

                    child: Column(
                      children: [

                        const Text(
                          "Sesudah",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 10),

                        imageAfter != null
                            ? Image.network(
                                imageAfter!.path,
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
                                    pickImage(ImageSource.camera, false),
                                child: const Text("Camera"),
                              ),
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    pickImage(ImageSource.gallery, false),
                                child: const Text("Gallery"),
                              ),
                            ),
                          ],
                        )

                      ],
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Ringkasan Solusi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: solusiController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Jelaskan solusi yang dilakukan...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Spare Parts",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: sparepartController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Spare parts yang digunakan...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

              onPressed: () async {

  try {

    await selesai(); 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pekerjaan berhasil diselesaikan"),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardTeknisi(),
      ),
    );

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
      ),
    );

  }

},

                child: const Text(
                  "Selesaikan Pekerjaan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

              ),
            )

          ],
        ),
      ),
    );
  }
}