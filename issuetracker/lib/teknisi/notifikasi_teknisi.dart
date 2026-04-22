import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotifikasiTeknisi extends StatefulWidget {
  const NotifikasiTeknisi({super.key});

  @override
  State<NotifikasiTeknisi> createState() => _NotifikasiTeknisiState();
}

class _NotifikasiTeknisiState extends State<NotifikasiTeknisi> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  String get _uid => supabase.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    if (_uid.isEmpty) return;
    try {
      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false);

      setState(() {
        notifications = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });

      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _uid)
          .eq('is_read', false);
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Color _iconColor(String? type) {
    switch (type) {
      case 'task_completed':
        return Colors.green;
      case 'new_task':
      case 'issue_assigned':
        return Colors.blue;
      case 'issue_in_progress':
        return Colors.orange;
      case 'issue_resolved':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _iconData(String? type) {
    switch (type) {
      case 'task_completed':
        return Icons.check_circle_outline;
      case 'new_task':
      case 'issue_assigned':
        return Icons.assignment_ind_outlined;
      case 'issue_in_progress':
        return Icons.build_outlined;
      case 'issue_resolved':
        return Icons.verified_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text(
          "Notifikasi",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: fetchNotifications,
            child: const Text('Refresh',
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada notifikasi',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      final bool isUnread = notif['is_read'] == false;
                      final String? type = notif['type']?.toString();

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUnread ? Colors.blue[50] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isUnread
                              ? Border.all(color: Colors.blue.shade200)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _iconColor(type).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_iconData(type),
                                  color: _iconColor(type), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif['title'] ?? 'Notifikasi',
                                          style: TextStyle(
                                            fontWeight: isUnread
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (isUnread)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif['message'] ?? '-',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    notif['created_at'] != null
                                        ? notif['created_at']
                                            .toString()
                                            .substring(0, 16)
                                            .replaceAll('T', ' ')
                                        : '',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}