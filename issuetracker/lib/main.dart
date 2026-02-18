import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ivzuhuebueotbjpfunxp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2enVodWVidWVvdGJqcGZ1bnhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzNTgzNTAsImV4cCI6MjA4NjkzNDM1MH0.rzB9-boI2ids70DLS2ptlRii6d_Wrp8dfZe5BSvu9BY'
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Issue Tracker',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          home: const AuthGate(),
        );
      },
    );
  }
}
