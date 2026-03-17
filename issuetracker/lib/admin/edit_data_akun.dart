import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class EditDataAkun extends StatefulWidget {
  final Map users;
  const EditDataAkun({super.key, required this.users});

  @override
  State<EditDataAkun> createState() => _EditDataAkunState();
}

class _EditDataAkunState extends State<EditDataAkun> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> issues = [];
  Map<String, dynamic>? issue;
  
  late TextEditingController nama;
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController nomor;


  @override
  void initState(){
    super.initState();

     nama = TextEditingController(text: widget.users['name']);
     email = TextEditingController(text: widget.users['email']);
    nomor  = TextEditingController(text: widget.users['phone']);
    password = TextEditingController();
       }

Future<void> updateProfile() async{
  final user = supabase.auth.currentUser;
  if(user == null) return;

  await supabase.auth.updateUser(UserAttributes(
    email :  email.text,
    password: password.text.isEmpty ? null : password.text,
    data: {
      'name' : nama.text,
      'phone' : nomor.text
    }
  ));
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
        title: const Text("Edit Data Akun"),
        backgroundColor: Colors.grey[200],
      ),
      body: SafeArea(child: Column(
        children: [
          Padding(padding: EdgeInsetsGeometry.all(12),
              child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                
              color: Colors.grey[100],
            ),
            
          ),
          
          ),
          SizedBox(height: 10),
          Text(
            'Nama Lengkap', style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          TextField(
            controller: nama,
           decoration: InputDecoration(
            hintText: 'Masukan Nama',
            contentPadding: EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)
            ),
           ),

          ),
                            SizedBox(height: 6),

           Text(
            'Email', style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          TextField(
            controller: email,
            decoration: InputDecoration(
              hintText: 'Masukan Email',
              contentPadding: EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
            ),
          ),
                  SizedBox(height: 6),

             Text(
            'Nomor Telepon', style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          TextField(
            controller: nomor,
            decoration: InputDecoration(
              hintText: 'Nomor Telepon',
              contentPadding: EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
            ),
          ),
                            SizedBox(height: 6),

        Text(
            'Password', style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          TextField(
              controller: password,
              decoration: InputDecoration(
              hintText: 'Password',
              contentPadding: EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
            ),
          ),
        const SizedBox(height: 28),
        SizedBox(                
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

    );
  }
}

