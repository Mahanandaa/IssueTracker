import 'package:flutter/material.dart';
import 'package:issuetracker/karyawan/edit_profile_karyawan.dart';
import 'package:issuetracker/main.dart';
import 'package:issuetracker/Auth/login.dart';



class profilesettingkaryawan extends StatefulWidget {
  const profilesettingkaryawan({super.key});

  @override
  State<profilesettingkaryawan> createState() =>
      _profilesettingkaryawanState();
}

class _profilesettingkaryawanState extends State<profilesettingkaryawan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("Profile dan Settings"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 26,
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [

                  Row(
                    children: [
                      Text(
                        'Mr.User | ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Karyawan',
                        style: TextStyle(
                          color: Color.fromARGB(255, 20, 121, 236),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6),
                  Text('user@gmail.com'),
                  Text('089512345678'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Pengaturan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileKaryawan()));
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 153, 160, 167),
                      
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                'Edit Profile Akun',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 14),

        
         Container(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 153, 160, 167),
        blurRadius: 5,
      )
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [

      const Text(
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
      ),

    ],
  ),
),


          const SizedBox(height: 15),
          Container(
             padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 153, 160, 167),                  blurRadius: 5,
                )
              ],
            ),
  child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const Text(
                  'Keluar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                  IconButton( icon: const Icon(Icons.exit_to_app_outlined, color: Colors.red,),
                  onPressed: () {
                    
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const Loginpage()));
                  },
                  
                  )                

              ],
            ),
          ),
          
        ],
        
      ),
      
    );
  }
}
