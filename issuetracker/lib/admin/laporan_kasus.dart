import 'package:flutter/material.dart';

class LaporanKasus extends StatefulWidget {
  const LaporanKasus({super.key});

  @override
  State<LaporanKasus> createState() => _LaporanKasusState();
}

class _LaporanKasusState extends State<LaporanKasus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Laporan"),
        backgroundColor: Colors.grey[200],

      ),
   body: SafeArea(
    child: Padding(padding: EdgeInsetsGeometry.all(12),
    
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              
            ),
          )
        ],
      ),
    
    ),
   ),
    );
  }
}