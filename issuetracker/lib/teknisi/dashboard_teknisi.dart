import 'package:flutter/material.dart';

class DashboardTeknisi extends StatefulWidget {
  const DashboardTeknisi({super.key});

  @override
  State<DashboardTeknisi> createState() => _DashboardTeknisiState();
}

class _DashboardTeknisiState extends State<DashboardTeknisi> {
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