import 'package:flutter/material.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
import 'package:issuetracker/kasus/kasus_database.dart';
import 'package:issuetracker/kasus/kasus_service.dart';


class TambahLaporan extends StatefulWidget {
  const TambahLaporan({super.key});

  @override
  State<TambahLaporan> createState() => _TambahLaporanState();
}

class _TambahLaporanState extends State<TambahLaporan> {

final kasus = Kasus();
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
          "New Issue",
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
                      selectKategori = 'IT Equipment';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 35),
                    decoration: BoxDecoration(
                      color: selectKategori == 'IT Equipment'
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1.5),
                    ),
                    child: Text(
                      'IT Equipment',
                      style: TextStyle(
                        color: selectKategori == 'IT Equipment'
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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectKategori = 'Cleaning';
                    });
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
                      color: selectPrioritas == 'Low'  ? Colors.green : Colors.white,
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardKaryawan(),
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
