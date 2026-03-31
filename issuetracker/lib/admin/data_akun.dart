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
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("Data Akun"),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Ananda MY',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          CircleAvatar(
                            radius: 24,
                            child: Icon(Icons.person),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Text('Email: ananda@gmail.com'),
                      SizedBox(height: 4),
                      Text('Nomor: 08001201231'),
                      SizedBox(height: 4),
                      Text('Password: password123@907'),

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 10),
                          Icon(Icons.delete, color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),

                  Text(
                    'Data admin',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Ananda MY',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          CircleAvatar(
                            radius: 24,
                            child: Icon(Icons.person),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Text('Email: ananda@gmail.com'),
                      SizedBox(height: 4),
                      Text('Nomor: 08001201231'),
                      SizedBox(height: 4),
                      Text('Password: qwsd22@'),

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 10),
                          Icon(Icons.delete, color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}