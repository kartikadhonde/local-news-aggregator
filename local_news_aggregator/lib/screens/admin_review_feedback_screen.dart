import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminReviewFeedbackScreen extends StatelessWidget {
  const AdminReviewFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('feedback')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No feedback yet'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final status = (data['status'] ?? 'new') as String;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(data['message'] ?? ''),
                subtitle: Text('${data['userEmail'] ?? 'Unknown'} • ${DateTime.fromMillisecondsSinceEpoch((data['createdAt'] as Timestamp).millisecondsSinceEpoch)}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'resolve') {
                      await docs[index].reference.update({'status': 'resolved'});
                    } else if (value == 'delete') {
                      await docs[index].reference.delete();
                    }
                  },
                  itemBuilder: (context) => [
                    if (status != 'resolved')
                      const PopupMenuItem(value: 'resolve', child: Text('Mark resolved')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                leading: Icon(
                  status == 'resolved' ? Icons.check_circle : Icons.pending,
                  color: status == 'resolved' ? Colors.green : Colors.orange,
                ),
              ),
            );
          },
        );
      },
    );
  }
}


