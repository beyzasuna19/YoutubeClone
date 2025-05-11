import 'package:flutter/material.dart';
import 'package:youtubeclone/screens/home_screen.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({Key? key}) : super(key: key);

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const Scaffold(body: Center(child: Text('Shorts'))),
    const Scaffold(body: Center(child: Text('Create'))),
    const Scaffold(body: Center(child: Text('Subscriptions'))),
    const Scaffold(body: Center(child: Text('Library'))),
  ];

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.add_circle_outline,
    Icons.subscriptions_outlined,
    Icons.video_library_outlined,
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _icons.length,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade800,
                width: 0.5,
              ),
            ),
          ),
          child: TabBar(
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: _icons
                .asMap()
                .map((i, e) => MapEntry(
                      i,
                      Tab(
                        icon: Icon(
                          e,
                          color: _selectedIndex == i
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ))
                .values
                .toList(),
            indicatorColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}