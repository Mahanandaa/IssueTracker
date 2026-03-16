import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TidakSelesai extends StatefulWidget {
  const TidakSelesai({super.key});

  @override
  State<TidakSelesai> createState() => _TidakSelesaiState();
}

class _TidakSelesaiState extends State<TidakSelesai> {

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> issues = [];
  Future<void> notCompleted() async{
  final response = await supabase.from('issues').select();
  setState(() {
    issues = List<Map<String,dynamic>>.from(response);
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tidak Selesai"),
        backgroundColor: Colors.grey[200],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
             Expanded(child: Container(
             padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
           color: const Color.fromARGB(255, 245, 242, 242),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4
              )
            ]
            ),
            child: Column(
              children: [
                Text('Judul', style: TextStyle(fontWeight: FontWeight.w600),),
                Text('Alasan : ' ,style: TextStyle(fontWeight: FontWeight.w600),),
                Text('Diperlukan teknisi yang lebih handal', style: TextStyle(fontStyle: FontStyle.italic),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Text('Lokasi: Lantai 1 '),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                      ),
                      child: GestureDetector(
                        onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardAdmin()));
                      },
                      child: Text(
                    'Detail',

                      ),
                      ),

                    ),
                    
                   
                  ],
                )   
              ],
              
            ),
          
          
                       ),
             
             
             ),

            ],
          ),
        ),
      ),
    );
  }
}