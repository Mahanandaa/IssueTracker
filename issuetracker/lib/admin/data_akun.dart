import 'package:flutter/material.dart';

class DataAkun extends StatefulWidget {
  const DataAkun({super.key});

  @override
  State<DataAkun> createState() => _DataAkunState();
}

class _DataAkunState extends State<DataAkun> {
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
            Text('Data Karyawan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey)
              ),
            ),
            Row(
              children: [
                Text('Nama : Ananda MY'),
                CircleAvatar(radius: 26,
                child: Icon(Icons.person),),

              ],
            ),
            Column(
              children: [
                Text('Email : ananda@gmail.com'),
                Text('Nomor : 08001201231'),
              
              ],
            ),
            Row(
              children: [
                Text('Password : qwsd22@'),
                Icon(Icons.edit),
                Icon(Icons.delete)
              ],
            ),


             Text('Data Karyawan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey)
              ),
            ),
            Row(
              children: [
                Text('Nama : Ananda MY'),
                CircleAvatar(radius: 26,
                child: Icon(Icons.person),),

              ],
            ),
            Column(
              children: [
                Text('Email : ananda@gmail.com'),
                Text('Nomor : 08001201231'),
              
              ],
            ),
            Row(
              children: [
                Text('Password : qwsd22@'),
                Icon(Icons.edit),
                Icon(Icons.delete)
              ],
            ),
          ],
          
        ),
       ),
      ),
    );
  }
}