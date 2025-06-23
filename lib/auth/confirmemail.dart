import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfirmEmailPage extends StatefulWidget {
  const ConfirmEmailPage({super.key});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool loading = false;

  Future<void> checkEmailVerification() async {
    setState(() => loading = true);
    try {
      User? user = _auth.currentUser;
      await user?.reload();
      if (user != null && user.emailVerified) {
        setState(() => isEmailVerified = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email is not verified yet.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Please verify your email address by clicking the link sent to your email. Once done, click below:",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: checkEmailVerification,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("I Verified My Email"),
            ),
            const SizedBox(height: 24),
            if (isEmailVerified)
              const Text(
                "Email verified! You can now proceed.",
                style: TextStyle(color: Colors.green, fontSize: 16),
              )
          ],
        ),
      ),
    );
  }
}