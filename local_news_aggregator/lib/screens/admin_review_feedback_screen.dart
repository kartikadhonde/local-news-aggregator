import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminReviewFeedbackScreen extends StatelessWidget {
  const AdminReviewFeedbackScreen({super.key});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    try {
      return DateFormat(
        'MMM dd, yyyy • hh:mm a',
      ).format((timestamp as Timestamp).toDate());
    } catch (e) {
      return 'Unknown date';
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    DocumentReference ref,
    String action,
  ) async {
    try {
      if (action == 'delete') {
        await ref.delete();
      } else {
        await ref.update({'status': action == 'resolve' ? 'resolved' : 'new'});
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'delete' ? 'Feedback deleted' : 'Feedback updated',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('feedback')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Trigger rebuild
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feedback_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No feedback yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final status = (data['status'] ?? 'new') as String;
            final userName = data['userName'] ?? 'Unknown User';
            final userEmail = data['userEmail'] ?? 'Unknown Email';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ExpansionTile(
                leading: Icon(
                  status == 'resolved' ? Icons.check_circle : Icons.pending,
                ),
                title: Text(userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(userEmail, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(data['createdAt']),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) =>
                      _updateStatus(context, docs[index].reference, value),
                  itemBuilder: (context) => [
                    if (status != 'resolved')
                      const PopupMenuItem(
                        value: 'resolve',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Mark resolved'),
                          ],
                        ),
                      )
                    else
                      const PopupMenuItem(
                        value: 'unresolve',
                        child: Row(
                          children: [
                            Icon(Icons.pending, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text('Mark as new'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Feedback Message:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            data['message'] ?? 'No message',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: status == 'resolved'
                                    ? Colors.green[50]
                                    : Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: status == 'resolved'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              child: Text(
                                status == 'resolved' ? 'RESOLVED' : 'NEW',
                                style: TextStyle(
                                  color: status == 'resolved'
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
