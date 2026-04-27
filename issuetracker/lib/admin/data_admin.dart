import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:issuetracker/admin/data_akun.dart';
import 'package:issuetracker/admin/kasus_admin.dart';
import 'package:issuetracker/admin/laporan_kasus.dart';
import 'package:issuetracker/admin/profile_admin.dart';
import 'package:issuetracker/admin/tidak_selesai.dart';
import 'kasus_ditolak.dart';
class DataAdmin extends StatefulWidget {
  const DataAdmin({super.key});

  @override
  State<DataAdmin> createState() => _DataAdminState();
}

class _DataAdminState extends State<DataAdmin> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Data Admin "),
        backgroundColor: Colors.grey[200],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Kasus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage_rounded),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardAdmin(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KasusAdmin(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DataAdmin(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileAdmin(),
              ),
            );
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [


              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DataAkun()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12, right: 6),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x19000000),
                              blurRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                          
                            Icon(Icons.people, size: 40, color: Colors.blue[600]),
                            const SizedBox(height: 12),
                            const Text(
                              'Data Akun',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                           Icon(
                            Icons.arrow_forward, color: Colors.blue, size: 20,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TidakSelesai()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12, left: 6),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x19000000),
                              blurRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.timer_off, size: 40, color: Colors.orange[600]),
                            const SizedBox(height: 12),
                            const Text(
                              'Tidak Selesai',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.arrow_forward, color: Colors.orange, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),



              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => KasusDitolak()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12, right: 6),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x19000000),
                              blurRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.cancel, size: 40, color: Colors.red[600]),
                            const SizedBox(height: 12),
                            const Text(
                              'Kasus Ditolak',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.arrow_forward, color: Colors.red, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LaporanKasus()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12, left: 6),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x19000000),
                              blurRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.assessment, size: 40, color: Colors.blue[700]),
                            const SizedBox(height: 12),
                            const Text(
                              'Detail Laporan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.arrow_forward, color: Colors.blue, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}