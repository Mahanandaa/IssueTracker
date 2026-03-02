import 'package:flutter/material.dart';

class HistoryTeknisi extends StatefulWidget {
  const HistoryTeknisi({super.key});

  @override
  State<HistoryTeknisi> createState() => _HistoryTeknisiState();
}

class _HistoryTeknisiState extends State<HistoryTeknisi> {
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