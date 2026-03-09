import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/reject_laporan_teknisi.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:issuetracker/teknisi/progress_teknisi.dart';
class DetailLaporanTeknisi extends StatefulWidget {
  final String issueId;

  const DetailLaporanTeknisi({super.key, required this.issueId});

  @override
  State<DetailLaporanTeknisi> createState() =>
      _DetailLaporanTeknisiState();
}

class _DetailLaporanTeknisiState
    extends State<DetailLaporanTeknisi> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? issue;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }
Future<void> fetchDetail() async {
  try {
    final data = await supabase
        .from('issues')
        .select()
        .eq('id', widget.issueId)
        .maybeSingle(); 

    if (data != null) {
      setState(() {
        issue = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  } catch (e) {
    debugPrint("ERROR DETAIL: $e");
    setState(() {
      isLoading = false;
    });
  }
}

Widget infoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color.fromARGB(246, 235, 242, 248),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style:  TextStyle(fontSize: 20, color: Colors.blue[700], fontWeight: FontWeight.w600),
            
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("Laporan"),
        
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue?['title'] ?? 'WiFi ERROR',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: infoBox(
                              'Kategori', 
                              issue?['category'] ?.toString() ??
                                  'Urgent'),
                                  
                        ),
                        
                        const SizedBox(width: 12),
                        Expanded(
                          child: infoBox(
                              'Lokasi',
                              issue?['location']
                                      ?.toString() ??
                                  'Lantai 1'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: infoBox(
                              'Tanggal ',
                               issue?['created_at']
                               ?.toString().substring(0, 10) ??
                              'Testing', ),
                                
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: infoBox(
                              'Status',
                              issue?['status']
                                      ?.toString() ??
                                  'Panding'),
                        ),
                      ],
                    ),
                      const SizedBox(height: 24),
            const Text('Deskripsi',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 22)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
              child: Text(
                issue?['description']?.toString() ?? 'Wifi masih error semenjak hari kemarin',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          const SizedBox(height: 10),
          const Text('Foto',
          style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 22
          ),),
          SizedBox(height: 10),
          Container(
width: double.infinity,
              height: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
              child: Text(
                issue?['photo_url']?.toString() ?? 'Foto Tidak Ditemukan..',
                style: const TextStyle(fontSize: 16),
              ),
          ),
const SizedBox(height: 30),

Row(
  children: [
    Expanded(
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProgressTeknisi(),
              ),
            );
          },
          child: const Text(
            'Terima',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white
            ),
          ),
        ),
      ),
    ),
    const SizedBox(width: 12),
   Expanded(
  child: SizedBox(
    height: 48,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RejectLaporanTeknisi(
              issueId: issue!['id'].toString(),
            ),
          ),
        );

      },
      child: const Text(
        'Tolak',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white
        ),
      ),
    ),
  ),
)
  ],
),
                  ],
                  
                ),
                
               ),
                      
            ),
    );
  }

  
}