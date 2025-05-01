import 'package:flutter/material.dart';
import 'auth/pick_role.dart';
import 'auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Ensure binding before anything else
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<Widget> _startPage = _determineStartPage();

  static Future<Widget> _determineStartPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // You requested this line to always run
    await prefs.setString('val', 'false');

    String? val = prefs.getString('val');

    if (val == 'true') {
      return PickRolePage();
    } else {
      return LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conditional Navigation',
      home: FutureBuilder<Widget>(
        future: _startPage,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data ?? Scaffold(
              body: Center(child: Text('Unexpected error.')),
            );
          } else {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
