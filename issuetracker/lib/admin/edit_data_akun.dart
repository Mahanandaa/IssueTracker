import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class EditDataAkun extends StatefulWidget {
  const EditDataAkun({super.key});

  @override
  State<EditDataAkun> createState() => _EditDataAkunState();
}

class _EditDataAkunState extends State<EditDataAkun> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> issues = [];
  Map<String, dynamic>? issue;
  
  @override
  void initState(){
    super.initState();
    fetchIssuedata();
  }
  Future<void> fetchIssuedata() async{
  final response = await supabase.from('issues').select();
  setState(() {
    issues = List<Map<String, dynamic>>.from(response);
  });
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
            decoration: InputDecoration(
              hintText: 'Password',
              contentPadding: EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
            ),
          ),

           SizedBox(height: 22),
                  SizedBox(
                    width: 211,
                    height: 45,
                    child: TextButton(
                      onPressed: () => (context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Edit',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
        ],
      ),
      ),

    );
  }
}

