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
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text(
                'Data Karyawan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Nama : Ananda MY'),
                  CircleAvatar(
                    radius: 26,
                    child: Icon(Icons.person),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Email : ananda@gmail.com'),
                  Text('Nomor : 08001201231'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Password : qwsd22@'),
                  Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Icon(Icons.delete),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Data Karyawan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Nama : Ananda MY'),
                  CircleAvatar(
                    radius: 26,
                    child: Icon(Icons.person),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Email : ananda@gmail.com'),
                  Text('Nomor : 08001201231'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Password : qwsd22@'),
                  Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Icon(Icons.delete),
                    ],
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