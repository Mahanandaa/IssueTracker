import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/daftar.dart';
import 'package:issuetracker/karyawan/notifikasi_karyawan.dart';
import 'package:issuetracker/karyawan/setting_profile.dart';

class profilesettingkaryawan extends StatefulWidget {
  const profilesettingkaryawan({super.key});

  @override
  State<profilesettingkaryawan> createState() => _profilesettingkaryawanState();
}

class _profilesettingkaryawanState extends State<profilesettingkaryawan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile dan Settings"),
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