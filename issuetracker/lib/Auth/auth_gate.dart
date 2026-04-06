import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:issuetracker/Auth/login.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return FutureBuilder<String?>(
            key: ValueKey(session.user.id), // ← cegah rebuild berulang
            future: AuthService().getUserRole(session.user.id),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasError) {
                return const DashboardKaryawan(); // fallback jika error
              }

              final role = roleSnapshot.data;

              switch (role) {
                case 'admin':
                  return const DashboardAdmin();
                case 'teknisi':
                  return const DashboardTeknisi();
                case 'karyawan':
                default:
                  return const DashboardKaryawan();
              }
            },
          );
        } else {
          return const Loginpage();
        }
      },
    );
  }
}