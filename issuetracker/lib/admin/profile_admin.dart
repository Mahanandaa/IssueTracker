import 'package:flutter/material.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:issuetracker/Auth/login.dart';
import 'package:issuetracker/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileAdmin extends StatefulWidget {
  const ProfileAdmin({super.key});

  @override
  State<ProfileAdmin> createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<ProfileAdmin> {
    final authService = AuthService();
  final supabase = Supabase.instance.client;
  
  get data => null;
   void logout() async {
    await authService.keluar();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Loginpage()),
    );
  }
  @override
  Widget build(BuildContext context) {
        final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile Admin"),
        backgroundColor: Colors.grey[200],
      ),
      body: SafeArea(
       child: Padding(padding: EdgeInsetsGeometry.all(18),
        child: Row(
           children: [
                    Text(
                      data['name'] ?? 'Not Found',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data['role'] ?? 'Not Found',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 20, 121, 236),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(data['email'] ?? 'Not Found'),
                    Text(data['phone'] ?? 'Not Found'),

                    const SizedBox(height: 28),

                    GestureDetector(
                      onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileAdmin()));                    
                         },
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                  color: Color.fromARGB(255, 153, 160, 167),
                  blurRadius: 5,
                          ),
                        ],
                      
                      ),
                      child: Text(
                        'Edit Profile akun',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: 14),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 153, 160, 167),
                  blurRadius: 5,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tema Gelap',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
   ValueListenableBuilder(
                  valueListenable: themeNotifier,
                  builder: (context, ThemeMode mode, _) {
                    return Switch(
                      value: mode == ThemeMode.dark,
                      onChanged: (val) {
                        themeNotifier.value =
                            val ? ThemeMode.dark : ThemeMode.light;
                      },
                    );
                  },
                ),                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(255, 153, 160, 167),
                  blurRadius: 5,
                )
              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Keluar' , style: TextStyle(fontWeight: FontWeight.w600),
                          
                          ),

                            IconButton(onPressed: logout, icon: const Icon(Icons.exit_to_app))
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