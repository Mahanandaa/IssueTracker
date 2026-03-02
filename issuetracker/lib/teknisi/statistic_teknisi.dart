import 'package:flutter/material.dart';

class statistic extends StatefulWidget {
  const statistic({super.key});

  @override
  State<statistic> createState() => _statisticState();
}

class _statisticState extends State<statistic> {
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