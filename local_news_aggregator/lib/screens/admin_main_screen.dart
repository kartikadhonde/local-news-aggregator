import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'global_tab.dart';
import 'local_tab.dart';
import 'admin_review_feedback_screen.dart';
import 'profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const _AdminNewsHome(),
    const AdminReviewFeedbackScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: Text(
                  user.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.newspaper), label: 'News'),
          NavigationDestination(icon: Icon(Icons.feedback), label: 'Feedback'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _AdminNewsHome extends StatelessWidget {
  const _AdminNewsHome();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage News'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.location_on), text: 'Local'),
              Tab(icon: Icon(Icons.public), text: 'Global'),
            ],
          ),
        ),
        body: const TabBarView(children: [LocalTab(), GlobalTab()]),
      ),
    );
  }
}


