import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/daftar.dart';
import 'package:issuetracker/Auth/login.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IssueTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const DashboardKaryawan(), 
    );
  }
}
