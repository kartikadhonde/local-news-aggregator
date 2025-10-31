import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logSearch(String query, String userId) async {
    try {
      await _firestore.collection('searches').add({
        'query': query.toLowerCase(),
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail
    }
  }

  Stream<List<Map<String, dynamic>>> getTopSearches({int limit = 10}) {
    return _firestore
        .collection('searches')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          final Map<String, int> searchCounts = {};
          for (var doc in snapshot.docs) {
            final query = doc.data()['query'] as String? ?? '';
            if (query.isNotEmpty) {
              searchCounts[query] = (searchCounts[query] ?? 0) + 1;
            }
          }
          final List<Map<String, dynamic>> topSearches =
              searchCounts.entries
                  .map((e) => {'query': e.key, 'count': e.value})
                  .toList()
                ..sort(
                  (a, b) => (b['count'] as int).compareTo(a['count'] as int),
                );
          return topSearches.take(limit).toList();
        });
  }

  Future<int> getTotalUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getTotalFeedback() async {
    try {
      final snapshot = await _firestore.collection('feedback').get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getNewFeedbackCount() async {
    try {
      final snapshot = await _firestore
          .collection('feedback')
          .where('status', isEqualTo: 'new')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getRecentUsers() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final snapshot = await _firestore
          .collection('users')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
          )
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
