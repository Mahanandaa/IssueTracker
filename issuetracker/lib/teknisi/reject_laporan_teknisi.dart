import 'package:flutter/material.dart';
import 'dashboard_teknisi.dart';

class RejectLaporanTeknisi extends StatefulWidget {
  const RejectLaporanTeknisi({super.key});

  @override
  State<RejectLaporanTeknisi> createState() =>
      _RejectLaporanTeknisiState();
}

class _RejectLaporanTeknisiState
    extends State<RejectLaporanTeknisi> {

  final TextEditingController alasanController =
      TextEditingController();

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
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
                  hintText:
                      'Masukkan alasan penolakan...',
                  contentPadding : const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.blue.shade700,
                        width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {

                    if (alasanController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Alasan tidak boleh kosong"),
                        ),
                      );
                      return;
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const DashboardTeknisi(),
                      ),
                    );
                  },
                  child: const Text(
                    'Kirim Alasan',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
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