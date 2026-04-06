import 'package:flutter/material.dart';

class Tambahakun extends StatefulWidget {
  const Tambahakun({super.key});

  @override
  State<Tambahakun> createState() => _TambahakunState();
}

class _TambahakunState extends State<Tambahakun> {
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