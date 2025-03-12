import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth/login_page.dart';  
import 'auth/register_page.dart'; // Import the login page
import 'sharedpreferences/shared_pref.dart';
import 'auth/pick_role.dart';
import 'auth/register_therapist.dart';
import 'package:flutter/foundation.dart';  // Import foundation.dart for kReleaseMode

void main() {
  runApp(DevicePreview(
    enabled: !kReleaseMode,  // Fixed typo in 'kReleaseMode'
    builder: (context) => MyApp(),  // Replace with your main app widget
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User API Demo',
        locale: DevicePreview.locale(context), // Correctly set the locale using DevicePreview
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Remove the home property and use initialRoute instead
      initialRoute: '/',  // This specifies the starting route
      routes: {
        '/': (context) => const PickRolePage(),
        '/login': (context) => const LoginPage(),
        '/shared_prefs': (context) => const SharedPrefsDebugScreen(),  // Add this
         '/PickRolePage': (context) => const PickRolePage(),  // Add this
         '/RegisterPage': (context) =>  RegistrationPage(),  // Add this
         '/Therapist_Register': (context) =>  Therapist_Register(),  // Add this
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = false;
  final String _storageKey = 'user_data';

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_storageKey);
    if (storedData != null) {
      setState(() {
        _userData = jsonDecode(storedData);
      });
    }
  }

  Future<void> _fetchAndStoreData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.105:8080/user/111'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_storageKey, jsonEncode(data));
        
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _userData = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  Future<void> _clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    
    setState(() {
      _userData = {};
    });
  }

  void _goToLogin() {
    Navigator.pushNamed(context, '/RegisterPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: _goToLogin,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Data:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: _userData.isEmpty
                        ? const Text('No data stored')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _userData.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '${entry.key}: ${entry.value}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchAndStoreData,
              child: const Text('Fetch User Data'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearStoredData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Clear Stored Data'),
            ),
            const SizedBox(height: 20),
            // Login Button
            ElevatedButton(
              onPressed: _goToLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Go to Login',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}