import 'package:flutter/material.dart';

class DataAdmin extends StatefulWidget {
  const DataAdmin({super.key});

  @override
  State<DataAdmin> createState() => _DataAdminState();
}

class _DataAdminState extends State<DataAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: const [],
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