import 'package:flutter/material.dart';
import 'package:my_app/homepage/NextStepMain.dart';          // Next Step page
import 'package:my_app/homepage/createBox.dart';            // Create Box page
import 'package:my_app/homepage/createCatgeory.dart';       // Categories page
import 'package:my_app/homepage/the_game.dart';             // AAC Grid
import 'navigation.dart';                                   // Bottom nav

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  int _selectedIndex = 0;

  // All tab views (pages) are stored here
  final List<Widget> _screens = [
     CreateBoxPage(),                                 // 0
                                 // 1 (AAC Grid)
     CreateCategoryPage(),                            // 2
     NextStepMainApp(),                                  // 3
    const Center(child: Text('Notifications Page')),       // 4
    const Center(child: Text('Profile Page')),             // 5
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─────────── Drawer ───────────
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Panel', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            _drawerItem(Icons.grid_view, 'Create Box', 0),
            _drawerItem(Icons.gamepad, 'AAC Grid', 1),
            _drawerItem(Icons.category, 'Categories', 2),
            _drawerItem(Icons.next_plan, 'Next Step', 3),
            _drawerItem(Icons.notifications, 'Notifications', 4),
            _drawerItem(Icons.person, 'Profile', 5),
          ],
        ),
      ),

      // ─────────── AppBar ───────────
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      // ─────────── Body with persistent state ───────────
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // ─────────── Bottom Nav ───────────
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }

  // Helper to avoid repeating drawer item layout
  ListTile _drawerItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);      // close drawer
        _onTabSelected(index);       // switch page
      },
    );
  }
}
