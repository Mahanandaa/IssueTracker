import 'package:supabase_flutter/supabase_flutter.dart';
import 'issuesModel.dart';

class IssueService {
  final _database = Supabase.instance.client.from('issues');

  // CREATE
  Future<void> createIssue(IssueModel newIssue) async {
    await _database.insert(newIssue.toMap());
  }
  // READ 
  Stream<List<IssueModel>> getIssuesStream() {
    return Supabase.instance.client.from('issues')
        .stream(primaryKey: ['id']).map((data) =>
        data.map((issueMap) => IssueModel.fromMap(issueMap)).toList());
  }

  // UPDATE
  Future<void> updateIssue({
    required String id,
    required String title,
    required String description,
    required String category,
    required String priority,
    required String location,
  }) async {
    await _database.update({
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'location': location,
      'updated_at': DateTime.now().toString(),
    }).eq('id', id);
  }
  // DELETE
  Future<void> deleteIssue(String id) async {
    await _database.delete().eq('id', id);
  }
}
