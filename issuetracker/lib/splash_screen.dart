import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:issuetracker/Auth/auth_gate.dart';
import 'Auth/login.dart';
import 'admin/dashboard_admin.dart';
import 'admin/data_admin.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
  with SingleTickerProviderStateMixin{
@override
void initState(){
  super.initState();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  Future.delayed(Duration(seconds: 2), () {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate())
    );
  });
}
  
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body:Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.track_changes_outlined,
          size: 90,
          color: Colors.white,
        ),
          Text('IssueTrack.', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2.0, shadows: [
            Shadow(
              blurRadius: 15.0,
              color: Colors.black26,
            )
          ]),),
           const SizedBox(height: 8),
            Text(
              'Professional Tracking Solution',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w300,
              ),
            ),
        ],
      ),
    ) ,
  );
  }
  }