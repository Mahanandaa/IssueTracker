import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailLaporanKaryawan extends StatefulWidget {
  final String issueId;

  const DetailLaporanKaryawan({super.key, required this.issueId});

  @override
  State<DetailLaporanKaryawan> createState() =>
      _DetailLaporanKaryawanState();
}

class _DetailLaporanKaryawanState
    extends State<DetailLaporanKaryawan> {
  final supabase = Supabase.instance.client;

  final commentController = TextEditingController();
  final feedbackController = TextEditingController();
  final ratingController = TextEditingController();

  Map<String, dynamic>? issue;
  List comments = [];

  String get uid => supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final i = await supabase
        .from('issues')
        .select()
        .eq('id', widget.issueId)
        .single();

    final c = await supabase
        .from('comments')
        .select()
        .eq('issue_id', widget.issueId);

    setState(() {
      issue = i;
      comments = c;
    });
  }

  Future<void> kirimKomentar() async {
    if (commentController.text.isEmpty) return;

    await supabase.from('comments').insert({
      'issue_id': widget.issueId,
      'user_id': uid,
      'comment': commentController.text,
    });

    commentController.clear();
    fetchData();
  }

  Future<void> kirimRating() async {
    final rating = int.tryParse(ratingController.text);

    if (rating == null || rating < 1 || rating > 5) return;

    await supabase.from('ratings').insert({
      'issue_id': widget.issueId,
      'rating': rating,
      'feedback': feedbackController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (issue == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(issue!['title'] ?? '',
                style: const TextStyle(fontSize: 20)),

            const SizedBox(height: 20),

            // komentar list
            Expanded(
              child: ListView(
                children: comments
                    .map((c) => Text("- ${c['comment']}"))
                    .toList(),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration:
                        const InputDecoration(hintText: 'Komentar'),
                  ),
                ),
                IconButton(
                  onPressed: kirimKomentar,
                  icon: const Icon(Icons.send),
                )
              ],
            ),

            const SizedBox(height: 20),
            TextField(
              controller: feedbackController,
              decoration:
                  const InputDecoration(hintText: 'Feedback'),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final rate = int.tryParse(newValue.text);
                  if (rate == null || rate < 1 || rate > 5) return oldValue;
                  return newValue;
                }),
              ],
              decoration:
                  const InputDecoration(hintText: 'Rating (1-5)'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: kirimRating,
              child: const Text('Kirim Rating'),
            ),
          ],
        ),
      ),
    );
  }
}