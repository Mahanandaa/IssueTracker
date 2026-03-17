import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAdminProfile extends StatefulWidget {
  final Map users;
  const EditAdminProfile({super.key, required this.users});

  @override
  State<EditAdminProfile> createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {

  final supabase = Supabase.instance.client;

  late TextEditingController nama;
  late TextEditingController email;
  late TextEditingController password;

  @override
  void initState(){
    super.initState();
    nama = TextEditingController(text: widget.users['name']);
    email = TextEditingController(text: widget.users['email']);
    password = TextEditingController();

  }
  Future<void> updateProfile() async{
    final user = supabase.auth.currentUser;
    if (user == null) return;


    await supabase.auth.updateUser(
      UserAttributes(
        email:  email.text,
        password: password.text.isEmpty ? null : password.text,
        data: {
          'name' : nama.text,
        }
      )
    );
    await supabase.from('users').update({
      'name' : nama.text,
      'email' : email.text,
    }).eq('id', user.id);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("edit profile admin"),
        backgroundColor: Colors.grey[200],
      ),
      body: SafeArea(
       child: Padding(padding: EdgeInsetsGeometry.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Edit Nama', style: TextStyle(fontWeight: FontWeight.w600),),
              TextField(
            controller: nama,
                decoration: InputDecoration(
                
                  hintText: "Masukan nama baru",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade100)
                  )
                ),
              ),
              Text('Edit Email' , style: TextStyle(fontWeight: FontWeight.w600),),
              TextField(
                controller: email,
                decoration: InputDecoration(
                  hintText: "Masukan email baru",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade100)
                  )
                ),
              ),
              Text('Masukan Password Baru', style: TextStyle(fontWeight: FontWeight.w600),),
              TextField(
                controller: password,
                decoration: InputDecoration(
                  hintText: "Masukan Password Baru",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade100)
                  )
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                
                child: TextButton(onPressed: updateProfile,style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  )

                ), child: Text(
                  'submit', style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                ))
              ),
            ],
          ),
        ),
       ),
      ),
    );
  }
}