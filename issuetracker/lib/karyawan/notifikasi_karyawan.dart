import 'package:flutter/material.dart';
import 'package:issuetracker/karyawan/setting_profile.dart';

class NotifikasiKaryawan extends StatefulWidget {
  const NotifikasiKaryawan({super.key});

  @override
  State<NotifikasiKaryawan> createState() => _NotifikasiKaryawanState();
}

class _NotifikasiKaryawanState extends State<NotifikasiKaryawan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        
        title: Text("Notifikasi",
        style: TextStyle(
          fontWeight: FontWeight.w600
        ),
        ),
       
      ),
      
      body: SafeArea(
        
        child: Column(
                  children: [
SizedBox(height: 22),
Container(
  margin: EdgeInsets.only(left: 40, right: 40),
  padding: EdgeInsets.all(15),
  width: MediaQuery.of(context).size.width * 0.9,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(9),
    color: Colors.grey[200],
    boxShadow: [
      BoxShadow(
        color: Color(0x19000000),
        blurRadius: 5,
        offset: Offset(0, 10),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [
      Container(
          ),
      Text(
        'Tidak ada Air',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),

    

      Text(
        'Urgent',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w500,
          fontSize: 19,
        ),
      ),

      Text(
        'Komentar : alat - alat tidak ada',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
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