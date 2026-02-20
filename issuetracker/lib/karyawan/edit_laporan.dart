import 'package:flutter/material.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
import 'package:issuetracker/kasus/issuesDatabase.dart';
import 'package:issuetracker/kasus/issuesModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class EditLaporan extends StatefulWidget {
  const EditLaporan({super.key});

  @override
  State<EditLaporan> createState() => _EditLaporanState();
}

class _EditLaporanState extends State<EditLaporan> {
  
final issueService = IssueService();
final judul = TextEditingController();
final lokasi = TextEditingController();
final deskripsi = TextEditingController();


  String? selectKategori;
  String? selectPrioritas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 20),
            const Text(
              'Judul Masalah',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
                controller: judul,
                decoration: InputDecoration(
                hintText: 'Masukan judul masalah',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Lokasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lokasi,
                decoration: InputDecoration(
                hintText: 'Lokasi',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Kategori',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectKategori = 'IT ';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 35),
                    decoration: BoxDecoration(
                      color: selectKategori == 'IT '
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1.5),
                    ),
                    child: Text(
                      'IT ',
                      style: TextStyle(
                        color: selectKategori == 'IT '
                            ? Colors.white
                            : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectKategori = 'Facilities';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 35),
                    decoration: BoxDecoration(
                      color: selectKategori == 'Facilities'
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1.5),
                    ),
                    child: Text(
                      'Facilities',
                      style: TextStyle(
                        color: selectKategori == 'Facilities'
                            ? Colors.white
                            : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                 GestureDetector(
                  onTap: () {
                    setState(() {
                      selectKategori = 'Electrical';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 35),
                    decoration: BoxDecoration(
                      color: selectKategori == 'Electrical'
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1.5),
                    ),
                    child: Text(
                      'Electrical',
                      style: TextStyle(
                        color: selectKategori == 'Electrical'
                            ? Colors.white
                            : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectKategori = 'Cleaning';                   });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 35),
                    decoration: BoxDecoration(
                      color: selectKategori == 'Cleaning'
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1.5),
                    ),
                    child: Text(
                      'Cleaning',
                      style: TextStyle(
                        color: selectKategori == 'Cleaning'
                            ? Colors.white
                            : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectKategori = 'Security';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 35),
                    decoration: BoxDecoration(
                      color: selectKategori == 'Security'
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1.5),
                    ),
                    child: Text(
                      'Security',
                      style: TextStyle(
                        color: selectKategori == 'Security'
                            ? Colors.white
                            : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                                const SizedBox(width: 15),
                 GestureDetector(
                  onTap: () {
                    setState(() {
                      selectKategori = 'Plumbing';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 35),
                    decoration: BoxDecoration(
                      color: selectKategori == 'Plumbing'
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1.5),
                    ),
                    child: Text(
                      'Plumbing',
                      style: TextStyle(
                        color: selectKategori == 'Plumbing'
                            ? Colors.white
                            : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                ),
                 const SizedBox(width: 15),
                  GestureDetector(
                  onTap: () {
                    setState(() {
                      selectKategori = 'Other';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 35),
                    decoration: BoxDecoration(
                      color: selectKategori == 'Other'
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1.5),
                    ),
                    child: Text(
                      'Other',
                      style: TextStyle(
                        color: selectKategori == 'Other'
                            ? Colors.white
                            : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                ),
              ],
              
            ),
            const SizedBox(height: 22),
            const Text(
              "Prioritas",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => selectPrioritas = 'Low');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 18),
                    decoration: BoxDecoration(
                      color: selectPrioritas == 'Low' ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green, width: 1.5),
                    ),
                    child: Text(
                      "Low",
                      style: TextStyle(
                        color: selectPrioritas == 'Low' ? Colors.white : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() => selectPrioritas = 'Medium');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 18),
                    decoration: BoxDecoration(
                      color: selectPrioritas == 'Medium' ? Colors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange, width: 1.5),
                    ),
                    child: Text(
                      "Medium",
                      style: TextStyle(
                        color: selectPrioritas == 'Medium' ? Colors.white: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() => selectPrioritas = 'High');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 18),
                    decoration: BoxDecoration(
                      color: selectPrioritas == 'High'
                          ? Colors.red
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red, width: 1.5),
                    ),
                    child: Text(
                      "High",
                      style: TextStyle(
                        color: selectPrioritas == 'High' ? Colors.white : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                 GestureDetector(
                  onTap: () {
                    setState(() => selectPrioritas = 'Urgent');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 18),
                    decoration: BoxDecoration(
                      color: selectPrioritas == 'Urgent'
                          ? Colors.red
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red, width: 1.5),
                    ),
                    child: Text(
                      "Urgent",
                      style: TextStyle(
                        color: selectPrioritas == 'Urgent' ? Colors.white : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskirpsi',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  maxLength: 225,
                  
                  controller: deskripsi,
                  maxLines: null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 30),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    hintText: 'Tuliskan deskripsi masalah',
                  ),
                )
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              "Tambah Foto (Opsional)",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 32),
                  SizedBox(height: 8),
                  Text("Preview Foto"),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(           
                  child: TextButton(
                  style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  shadowColor: Colors.black26,
                ),
               onPressed: () async {

  if (selectKategori == null ||  selectPrioritas == null ||judul.text.isEmpty ||lokasi.text.isEmpty || deskripsi.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Semua field wajib diisi")),
    );
    return;
  }

  final updateIssue = IssueModel(
    title: judul.text.trim(),
    description: deskripsi.text.trim(),
    category: IssueCategory.values.firstWhere(
      (e) => e.name == selectKategori,
      orElse: () => IssueCategory.IT,
    ),
    status: IssueStatus.Pending,
    priority: IssuePriority.values.firstWhere(
      (e) => e.name == selectPrioritas,
      orElse: () => IssuePriority.Low, 
    ),
    location: lokasi.text,
    reportedBy: Supabase.instance.client.auth.currentUser?.id ?? 'karyawan',
    createdAt: DateTime.now(),
  );


  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const DashboardKaryawan(),
    ),
  );
},

                child: const Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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