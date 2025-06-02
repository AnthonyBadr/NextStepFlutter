import 'package:flutter/material.dart';
import 'auth/pick_role.dart';
import 'auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_preview/device_preview.dart';  // for DevicePreview
import 'package:flutter/foundation.dart';  // for kReleaseMode
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  final Future<Widget> _startPage = _determineStartPage();

  static Future<Widget> _determineStartPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // You requested this line to always run
    //options:
    // signedIn
    // notSignedIn 
    
    await prefs.setString('StatusSignIN', 'notSignedIn');

    String? val = prefs.getString('StatusSignIN');

    if (val == 'notSignedIn') {
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
