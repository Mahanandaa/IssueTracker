import 'dart:async';
import 'package:issuetracker/teknisi/tidak_selesai_teknisi.dart';
import 'selesai_teknis.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressTeknisi extends StatefulWidget {
  final String issueId;
  const ProgressTeknisi({super.key, required this.issueId});

  @override
  State<ProgressTeknisi> createState() => _ProgressTeknisiState();
}

class _ProgressTeknisiState extends State<ProgressTeknisi> {
  Duration duration = const Duration();
  Timer? timer;

  final TextEditingController note_parts = TextEditingController();
  final TextEditingController note_result = TextEditingController();

  final supabase = Supabase.instance.client;

  Future<void> noteRes() async {
    await supabase
        .from('issues')
        .update({'resolution_notes': note_result.text.trim()}).eq(
            'id', widget.issueId);
  }

  Future<void> sparePart() async {
    if (note_parts.text.trim().isEmpty) return;
    await supabase.from('spare_parts').insert({
      'issue_id': widget.issueId,
      'part_name': note_parts.text.trim(),
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    note_parts.dispose();
    note_result.dispose();
    super.dispose();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          duration = Duration(seconds: duration.inSeconds + 1);
        });
      }
    });
  }

  void _stopTimer() => timer?.cancel();

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Progress Pengerjaan"),
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    "$hours:$minutes:$seconds",
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Sedang berjalan...',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // FIX 1: Seksi foto dihapus — foto sebelum = foto dari karyawan (photo_url)
            const Text("Langkah Langkah Perbaikan",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: note_result,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Langkah langkah perbaikan...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),

            const SizedBox(height: 25),

            const Text("Notes",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              maxLines: 4,
              controller: note_parts,
              decoration: InputDecoration(
                hintText: "Tuliskan note...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        _stopTimer();
                        final h = twoDigits(duration.inHours);
                        final m = twoDigits(duration.inMinutes.remainder(60));
                        final s = twoDigits(duration.inSeconds.remainder(60));
                        final actualTime = "$h:$m:$s";

                        try {
                          await supabase
                              .from('issues')
                              .update({'actual_time': actualTime}).eq(
                                  'id', widget.issueId);
                          await noteRes();
                          await sparePart();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Data berhasil disimpan")),
                            );
                            // FIX 1&3: Tidak ada photoBeforeUrl dari sini
                            // foto sebelum diambil dari DB (photo_url) di SelesaiTeknis
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SelesaiTeknis(
                                  issueId: widget.issueId,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Gagal menyimpan data: $e")),
                            );
                          }
                        }
                      },
                      child: const Text("Selesai",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
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
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        _stopTimer();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TidakSelesaiTeknisi(issueId: widget.issueId),
                          ),
                        );
                      },
                      child: const Text("Tidak Selesai",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}