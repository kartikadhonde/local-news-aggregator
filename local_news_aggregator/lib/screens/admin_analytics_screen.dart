import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  int _totalUsers = 0;
  int _totalFeedback = 0;
  int _newFeedback = 0;
  int _recentUsers = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _analyticsService.getTotalUsers(),
        _analyticsService.getTotalFeedback(),
        _analyticsService.getNewFeedbackCount(),
        _analyticsService.getRecentUsers(),
      ]);

      setState(() {
        _totalUsers = results[0];
        _totalFeedback = results[1];
        _newFeedback = results[2];
        _recentUsers = results[3];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading stats: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dashboard Overview',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadStats,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stats Cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2,
                      children: [
                        _StatCard(
                          title: 'Total Users',
                          value: _totalUsers.toString(),
                          icon: Icons.people,
                        ),
                        _StatCard(
                          title: 'New (7 days)',
                          value: _recentUsers.toString(),
                          icon: Icons.person_add,
                        ),
                        _StatCard(
                          title: 'Total Feedback',
                          value: _totalFeedback.toString(),
                          icon: Icons.feedback,
                        ),
                        _StatCard(
                          title: 'Pending',
                          value: _newFeedback.toString(),
                          icon: Icons.pending,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Top Searches Section
                    const Text(
                      'Top Searches',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _analyticsService.getTopSearches(limit: 10),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('No search data yet'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final topSearches = snapshot.data!;

                        return Card(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: topSearches.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final search = topSearches[index];
                              final query = search['query'] as String;
                              final count = search['count'] as int;

                              return ListTile(
                                leading: Text('${index + 1}.'),
                                title: Text(query),
                                trailing: Text('$count searches'),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
