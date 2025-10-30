import 'package:flutter/material.dart';
import 'local_tab.dart';
import 'global_tab.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const NewsHomeScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.2),
        elevation: 3,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(
              Icons.newspaper,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class NewsHomeScreen extends StatelessWidget {
  const NewsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('News Aggregator'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 2,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelPadding: EdgeInsets.symmetric(horizontal: 12),
            tabs: [
              Tab(icon: Icon(Icons.location_on, size: 18), text: 'Local'),
              Tab(icon: Icon(Icons.public, size: 18), text: 'Global'),
            ],
          ),
        ),
        body: const TabBarView(children: [LocalTab(), GlobalTab()]),
      ),
    );
  }
}
