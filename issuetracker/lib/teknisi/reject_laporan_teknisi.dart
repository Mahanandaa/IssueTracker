import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_teknisi.dart';

class RejectLaporanTeknisi extends StatefulWidget {

  final String issueId;

  const RejectLaporanTeknisi({
    super.key,
    required this.issueId,
  });

  @override
  State<RejectLaporanTeknisi> createState() =>
      _RejectLaporanTeknisiState();
}

class _RejectLaporanTeknisiState extends State<RejectLaporanTeknisi> {

  final TextEditingController alasanController = TextEditingController();

  final supabase = Supabase.instance.client;
Future<void> rejectIssue() async {
  try {

    print("ISSUE ID = ${widget.issueId}");

    final response = await supabase
        .from('issues')
        .update({
          'status': 'Rejected',
          'reject_reason': alasanController.text.trim(),
        })
        .eq('id', widget.issueId)
        .select();

    print("SUCCESS UPDATE:");
    print(response);

  } catch (e) {

    print("SUPABASE ERROR:");
    print(e);
    rethrow;

  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Tolak Laporan"),
        backgroundColor: Colors.grey[300],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Alasan Tolak Kasus',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: alasanController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Masukkan alasan penolakan...',
                  contentPadding: const EdgeInsets.all(14),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade700,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
onPressed: () async {

  if (alasanController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Alasan tidak boleh kosong"),
      ),
    );
    return;
  }

  try {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await rejectIssue();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Laporan berhasil ditolak"),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardTeknisi(),
      ),
      (route) => false,
    );

  } catch (e) {

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );

  }

},
                  child: const Text(
                    'Kirim Alasan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
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