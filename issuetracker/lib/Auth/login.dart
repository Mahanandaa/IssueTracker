import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/daftar.dart';
import 'package:issuetracker/main.dart';
import 'package:issuetracker/karyawan/dashboard_karyawan.dart';
class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {

  final username = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                'IssueTracker.',
               
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Colors.blue[900],
                  
                ),
              ),

              SizedBox(height: 50),

              Container(
                padding: EdgeInsets.all(22),
                  width: 362,
                  height: 440,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(24, 150, 148, 148),
                      blurRadius: 24,
                      offset: Offset(0, 11),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Center(
                      child: Text(
                        'Selamat Datang',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: 6),

                    Center(
                      child: Text(
                        'Masuk ke akun IssueTrack sekarang !',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                    SizedBox(height: 28),

                    Text(
                      'Username',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    SizedBox(height: 8),

                    TextField(
                      controller: username,
                      decoration: InputDecoration(
                        hintText: 'Masukkan username',
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    SizedBox(height: 8),

                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                         hintText: 'Masukkan password',
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 45,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DashboardKaryawan()),
                            );
                          },
                          child: Text(
                            'Masuk',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Belum memiliki akun? Daftar',
                      style: TextStyle(
                        color: Colors.blue[400],
                        fontWeight: FontWeight.w500,
                      
                      ),
                      
                    ),
                    
                  ),
                  
                ],
              ),
                              
              ),
             ],
          ),
        ),
      ),
    );
  }
}
