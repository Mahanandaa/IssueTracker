
import 'package:flutter/material.dart';


class EditLaporan extends StatefulWidget {
  const EditLaporan({super.key});


  @override
  State<EditLaporan> createState() => _EditLaporanState();

}

class _EditLaporanState extends State<EditLaporan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: const [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            children: [],
        ),
      ),
    );
  }
}