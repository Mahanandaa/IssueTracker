import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:issuetracker/admin/data_akun.dart';
import 'package:issuetracker/admin/detail_laporan_admin.dart';
import 'package:issuetracker/admin/kasus_admin.dart';
import 'package:issuetracker/admin/kasus_ditolak.dart';
import 'package:issuetracker/admin/laporan_kasus.dart';
import 'package:issuetracker/admin/tidak_selesai.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';

class DataAdmin extends StatefulWidget {
  const DataAdmin({super.key});

  @override
  State<DataAdmin> createState() => _DataAdminState();
}

class _DataAdminState extends State<DataAdmin> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Dashboard"),
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
                builder: (context) => const DashboardAdmin(),
              ),
            );
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
   GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DataAkun()),
    );
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey[100],
      boxShadow: [
        BoxShadow(
          color: Color(0x19000000),
          blurRadius: 3,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text('Data Akun'),
        Icon(Icons.send, color: Colors.blue),
      ],
    ),
  ),
),
              GestureDetector(
                onTap: () {
                  
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TidakSelesai()));
                },
  child: Container(
                
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100], boxShadow: [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 3,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Tidak Selesai'),
                    Icon(Icons.send, color: Colors.blue),
                    
                  ],
                ),
              ),
              ),
            
            GestureDetector(
                onTap: () {
                  
                  Navigator.push(context, MaterialPageRoute(builder: (context) => KasusDitolak()));
                },
  child: Container(
                
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100], boxShadow: [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 3,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Kasus Ditolak'),
                    Icon(Icons.send, color: Colors.blue),
                    
                  ],
                ),
              ),
              ),
            
             GestureDetector(
                onTap: () {
                  
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LaporanKasus()));
                },
                child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100], boxShadow: [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 3,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Detail Laporan'),
                    Icon(Icons.send, color: Colors.blue),
                    
                  ],
                ),
              ),
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}