import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:issuetracker/admin/kasus_admin.dart';

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
     bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work), label: 'Kasus'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storage_rounded), label: 'Data'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
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
          } else if (index == 1 ){
            Navigator.push(context, MaterialPageRoute(builder: (context) => KasusAdmin()));
          } else if (index == 2){
            Navigator.push(context, MaterialPageRoute(builder: (context) => DataAdmin()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardAdmin()));
          }
        },
      ),

    backgroundColor: Colors.white,
      appBar: AppBar(
      title: const Text("Dashboard"),
      backgroundColor: Colors.grey[200],
          ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
        children: [
        Expanded(child:  Container(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300]
              ),
                  child: Row( 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text('Data Akun'),
                  Icon(Icons.send, color: Colors.blue,)
                ],
              
              ),
            )), Expanded(child:  Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                  Text('Tidak Selesai'),

                  Icon(Icons.send, color: Colors.blue,)
                ],
              
              ),
            )),
             Expanded(child:  Container(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300]
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text('Tolak Kasus'),
                  Icon(Icons.send, color: Colors.blue,)
                ],
              
              ),
            )),
             Expanded(child:  Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Laporan Kasus'),
                  Icon(Icons.send, color: Colors.blue,)
                ],
              
              ),
            ))
           
          ],
        ),
       ),
      )
    );
  }
}