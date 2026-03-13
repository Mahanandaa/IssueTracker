import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:issuetracker/admin/panggil_teknisi.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
class DetailLaporanAdmin extends StatefulWidget {
  final String issueId;
  const DetailLaporanAdmin({
    super.key, required this.issueId
  });

  @override
  State<DetailLaporanAdmin> createState() => _DetailLaporanAdminState();
}

class _DetailLaporanAdminState extends State<DetailLaporanAdmin> {
  final supabase = Supabase.instance.client;
  final comment = TextEditingController();
  bool isLoading = true;
    Map<String, dynamic>? issue;

  Future<void> komentar() async{
    await supabase.from('comments').insert({
    'comment' : comment.text.trim(),
    'issue_id' : widget.issueId,
    });
  }
  @override
  void iniState(){
    super.initState();
    fetchIssueDetail();
  }

  Future<void> fetchIssueDetail() async{
    try{
      final response = await supabase.from('issues').select().eq('id', widget.issueId).maybeSingle();
      if (mounted){
        setState(() {
          issue = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Laporan"),
        backgroundColor: Colors.grey[200],
      ),
     body: SafeArea(child: Padding(
      padding: EdgeInsetsGeometry.all(16),
     child: SingleChildScrollView(
      child: ListView(
        children: [
          Text(issue? ['title']?.toString() ?? '',
          style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 24
          ),
          
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 242, 242),
                borderRadius: BorderRadius.circular(12),
               boxShadow: [
                BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
               ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategori', 
                    style: TextStyle(fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey),),
                    Text(issue? ['category']?.toString() ?? '', style: TextStyle(fontSize: 16)
                    ),
                  ],
                ),
              ),
              ),
              SizedBox(width: 12),
              Expanded(child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 242, 242),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          
                        ),
                      ],


                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lokasi', 
                    style : TextStyle(
                      fontWeight: FontWeight.w600,
                       fontSize: 14,
                       color: Colors.grey
                    )),
                    SizedBox(height: 6),
                    Text(issue? ['location']?.toString() ?? '', style: TextStyle(fontSize: 16),)
                  ],
                ),
              ))
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 245, 242, 242),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,

                        ),
                      ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tanggal', style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey
                    ),
                    
                    
                    ),
                    Text(issue?['created_at']?.toString() ?? '', 
                    style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
              ),
              SizedBox(width: 12),
              Expanded(child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 242, 242),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                  )
                ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('status', 
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey
                    ),),
                    SizedBox(height: 6),
                    Text(issue?['status']?.toString() ?? '',
                    style: TextStyle(fontSize: 16),)
                  ],
                ),
              )
              )

            ],
          ),
          SizedBox(height: 16),
          Text('Deskripsi', style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 22
          ),),
          SizedBox(height: 16),
          Container(
            height: 150,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey, width: 0.5)
            ),
            child: Text(
              issue?['description'].toString() ?? '' ,
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 16),
          Text('Foto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
          SizedBox(height: 16),
          Container(
            height: 150,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: Colors.grey, width: 0.5)
            ),
            child: Text(issue?['photo_url'].toString() ?? ''),
          ),
          SizedBox(height: 16),
          Center(

          
          
          ),

          SizedBox(height: 10),
          Text('Komentar' , style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),),

          TextField(
            controller: comment,
            decoration: InputDecoration(
              hintText: 'Masukan Komentar',
              prefixIcon: Icon(Icons.send, color: Colors.blue),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              )
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: SizedBox(
                height: 50,
               child: ElevatedButton(
                onPressed: () async{
                try{
                  await komentar();
                 } catch (a){
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ERROR $a')));
                 }
                 Navigator.push(context, MaterialPageRoute(builder: (context)=> PanggilTeknisi()));
               }, 
               
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(14),
                  ),

                ),
                
       child: Text('Selesai' , style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),) )
              ))
            ],
            
          )
          
       ],
      ),
     
     ),
     
     )),
    );
  }
}