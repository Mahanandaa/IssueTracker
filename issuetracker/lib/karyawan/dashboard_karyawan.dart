import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/daftar.dart';
import 'package:issuetracker/karyawan/notifikasi_karyawan.dart';
import 'package:issuetracker/karyawan/setting_profile.dart';
import 'package:issuetracker/karyawan/tambah_laporan.dart';

class DashboardKaryawan extends StatefulWidget {
  const DashboardKaryawan({super.key});

  @override
  State<DashboardKaryawan> createState() => _DashboardKaryawanState();
}

class _DashboardKaryawanState extends State<DashboardKaryawan> {
  final search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TambahLaporan())
        );
      }),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(30),              
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selamat datang.',
                    style: TextStyle(
                      
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications, size: 30,),
                       onPressed: () {
                         Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => NotifikasiKaryawan()),
                         );
                       },
                        
                      ),
                      SizedBox(width: 20),
                     IconButton(
  icon: Icon(Icons.person, size: 30),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => profilesettingkaryawan(),
      ),
    );
  },
),

                    ],
                  ),
                ],
              ),
            ),

             SizedBox(height: 1),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 48,
                    padding:  EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow:  [
                        BoxShadow(
                          blurRadius: 2,
                          offset: Offset(0, 2),
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: search,
                      decoration:  InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari kasus...',
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                   SizedBox(width: 8),
                  Icon(
                    Icons.date_range_outlined,
                    color: Colors.blue[400],
                    size: 28,
                  ),
                ],
              ),
            ),

             SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [

    Container(
      padding: EdgeInsets.symmetric(horizontal: 70, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'All',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),

    Container(
      padding: EdgeInsets.symmetric(horizontal: 70, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Pending',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    Container(
      padding: EdgeInsets.symmetric(horizontal: 70, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Progress',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    Container(
      padding: EdgeInsets.symmetric(horizontal: 70, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Resolved',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

  
],

),
SizedBox(height: 45),
Container(
  padding: EdgeInsets.all(20),
width: MediaQuery.of(context).size.width * 0.9,
  decoration: BoxDecoration(
    boxShadow: [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 24,
                        offset: Offset(0, 11),
                      ),
                    ],
borderRadius: BorderRadius.circular(6),    
    color: Colors.grey[100],
  ),
child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tidak ada air',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 23,
          ),
        ),
        Container(
          
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
          
            'Urgent',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

      ],
    ),



    SizedBox(height: 6),

    Text(
      'Lokasi : Lantai 1',
      style: TextStyle(fontSize: 18),
    ),

    Text(
      '02 Februari 2026',
      style: TextStyle(fontSize: 16),
    ),
Row(
        mainAxisAlignment: MainAxisAlignment.end,
  children: [
     Container(
    padding: EdgeInsets.all(6),
    decoration: BoxDecoration(
    
    borderRadius: BorderRadius.circular(4),
    color: Colors.white
         ),
      child: Icon(
        Icons.delete,
        color: Colors.red,
        size: 18,
      ),
    ),
   SizedBox(width: 12),
Container(
      padding: EdgeInsets.all(6),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(4),
    color: Colors.white,
  
  ),
child: Icon(
  Icons.edit_document,
  color: Colors.orange[600],
  size: 18,
),
),
   SizedBox(width: 12),

    Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Pending',
        style: TextStyle(
          color: Colors.orange[900],
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    
    ),
   

  ],
  
)

  ],
),


),
          ],
          
        ),
      ),
    
    );
  }
}
