import 'package:flutter/material.dart';

class TherpasitHomePage extends StatelessWidget {
  const TherpasitHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TherpasitHomePage"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          "Welcome to the TherpasitHomePage Page!",
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
