import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class KasusDitolak extends StatefulWidget {
  const KasusDitolak({super.key});

  @override
  State<KasusDitolak> createState() => _KasusDitolakState();
}

class _KasusDitolakState extends State<KasusDitolak> {
  final supabase = Supabase.instance.client;
    Map<String, dynamic>? issue;
    List<Map<String, dynamic>> issues = [];


  @override
  void initState(){
    super.initState();
    fetchIssues();
  }
  Future<void>fetchIssues() async{
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
        title: const Text("Kasus Ditolak"),
        backgroundColor: Colors.grey[200],
      ),
     body: SafeArea(child: Padding(padding: 
     EdgeInsetsGeometry.all(20),
     child: Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            
            children: [
              Text(
                issue?['title']?.toString() ?? 'not found',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              ),
            Text(
           issue?['priority'] ?? 'Not Found',
           style: TextStyle(
            color: issue?['priority'] == 'Urgent' ? Colors.white : issue ?['priority'] == 'Medium' ? Colors.orange : Colors.green,
            fontWeight: FontWeight.w600,
           ),
            ),
            Column(
            children: [
              Text('Alasan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              Text(issue?['reject_reason']?.toString() ?? 'not found',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              
              ),

              Text('lokasi : ${issue?['location'] ?? 'not found'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
               )
            ],
            )
            ],
          ),
          
        ),

        
      ],
     ),
     )
     )
    );
  }
}