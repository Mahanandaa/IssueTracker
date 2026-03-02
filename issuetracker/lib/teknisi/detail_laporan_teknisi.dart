import 'package:flutter/material.dart';

class DetailLaporanTeknisi extends StatefulWidget {
  const DetailLaporanTeknisi({super.key});

  @override
  State<DetailLaporanTeknisi> createState() => _DetailLaporanTeknisiState();
}

class _DetailLaporanTeknisiState extends State<DetailLaporanTeknisi> {
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