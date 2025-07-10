import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_app/auth/login_page.dart';
import 'package:my_app/auth/test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/homepage/pageorg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ApiConfig.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class TherapistRegisterPage1 extends StatefulWidget {
  const TherapistRegisterPage1({super.key});

  @override
  State<TherapistRegisterPage1> createState() => _TherapistRegisterPage1State();
}

class _TherapistRegisterPage1State extends State<TherapistRegisterPage1> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoadingGoogle = false;
  bool isLoadingEmail = false;

  // ───────────────────────── Google flow ──────────────────────────
  Future<void> signInWithGoogle() async {
    setState(() => isLoadingGoogle = true);
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // always force account picker

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoadingGoogle = false);
        return; // user canceled
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final isNew = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (!isNew) {
        // user exists → stay here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This user already exists")),
        );
        await FirebaseAuth.instance.signOut(); // optional: keep auth state clean
        return;
      }

      // new user → proceed
      final user = userCredential.user!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TherapistRegisterPage2(
            email: user.email ?? '',
            password: '',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Email already registered with another sign-in method.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-in failed: ${e.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e")),
      );
    } finally {
      setState(() => isLoadingGoogle = false);
    }
  }

  // ───────────────────────── Email flow ───────────────────────────
Future<void> handleEmailContinue() async {
  final email = emailController.text.trim();
  final password = passwordController.text;
  final confirmPassword = confirmPasswordController.text;

  if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  setState(() => isLoadingEmail = true);

  try {
    // Attempt to create the user silently
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // If successful, delete the user immediately
    await userCredential.user?.delete();

    // Proceed to next page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TherapistRegisterPage2(
          email: email,
          password: password,
        ),
      ),
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This email is already registered. Please use another.")),
      );
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firebase error: ${e.message}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unexpected error: $e")),
    );
  } finally {
    setState(() => isLoadingEmail = false);
  }
}



  // ───────────────────────── UI ───────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Therapist Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const LinearProgressIndicator(value: .33, color: Colors.blue),
            const SizedBox(height: 16),
            const Text("Account Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Please provide your login credentials."),
            const SizedBox(height: 24),

            // Email / password fields
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock_outline),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: isLoadingEmail ? null : handleEmailContinue,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: isLoadingEmail
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continue with Email'),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("OR"),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            const SizedBox(height: 20),

            // Google button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: isLoadingGoogle
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Sign in with Google"),
                onPressed: isLoadingGoogle ? null : signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class TherapistRegisterPage2 extends StatefulWidget {
  final String email;
  final String password;

  const TherapistRegisterPage2({super.key, required this.email, required this.password});

  @override
  State<TherapistRegisterPage2> createState() => _TherapistRegisterPage2State();
}

class _TherapistRegisterPage2State extends State<TherapistRegisterPage2> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  String gender = 'Male';
  String maritalStatus = 'Single';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Therapist Registration"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const LinearProgressIndicator(value: 0.66, color: Colors.blue),
            const SizedBox(height: 16),
            const Text("Therapist", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("By signing up you are agreeing to our Terms and Privacy Policy"),
            const SizedBox(height: 24),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                prefixIcon: Icon(Icons.person),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                prefixIcon: Icon(Icons.person_outline),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              onChanged: (value) => setState(() => gender = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: maritalStatus,
              decoration: const InputDecoration(
                labelText: 'Marital Status',
                prefixIcon: Icon(Icons.family_restroom),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
              items: const [
                DropdownMenuItem(value: 'Single', child: Text('Single')),
                DropdownMenuItem(value: 'Married', child: Text('Married')),
                DropdownMenuItem(value: 'Divorced', child: Text('Divorced')),
                DropdownMenuItem(value: 'Widowed', child: Text('Widowed')),
              ],
              onChanged: (value) => setState(() => maritalStatus = value!),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TherapistRegisterPage3(
                  email: widget.email,
                  password: widget.password,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  gender: gender,
                  maritalStatus: maritalStatus,
                ),
              ),
            );
          },
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Next'),
        ),
      ),
    );
  }
}

class TherapistRegisterPage3 extends StatefulWidget {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String gender;
  final String maritalStatus;

  const TherapistRegisterPage3({
    super.key,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.maritalStatus,
  });

  @override
  State<TherapistRegisterPage3> createState() => _TherapistRegisterPage3State();
}

class _TherapistRegisterPage3State extends State<TherapistRegisterPage3> {
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Info"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const LinearProgressIndicator(value: 0.75, color: Colors.blue),
              const SizedBox(height: 16),
              const Text("Contact Info", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TherapistRegisterConfirmPage(
                  email: widget.email,
                  password: widget.password,
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  gender: widget.gender,
                  maritalStatus: widget.maritalStatus,
                  phone: phoneController.text,
                  address: addressController.text,
                ),
              ),
            );
          },
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text("Next"),
        ),
      ),
    );
  }
}


class TherapistRegisterConfirmPage extends StatefulWidget {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String gender;
  final String maritalStatus;
  final String phone;
  final String address;

  const TherapistRegisterConfirmPage({
    super.key,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.maritalStatus,
    required this.phone,
    required this.address,
  });

  @override
  State<TherapistRegisterConfirmPage> createState() => _TherapistRegisterConfirmPageState();
}

class _TherapistRegisterConfirmPageState extends State<TherapistRegisterConfirmPage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  String gender = '';
  String maritalStatus = '';

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController(text: widget.password);
    firstNameController = TextEditingController(text: widget.firstName);
    lastNameController = TextEditingController(text: widget.lastName);
    phoneController = TextEditingController(text: widget.phone);
    addressController = TextEditingController(text: widget.address);
    gender = widget.gender;
    maritalStatus = widget.maritalStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Info"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const LinearProgressIndicator(value: 1.0, color: Colors.blue),
              const SizedBox(height: 16),
              const Text("Review & Edit Your Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildField("Email", emailController, Icons.email),
              _buildField("Password", passwordController, Icons.lock, obscure: true),
              _buildField("First Name", firstNameController, Icons.person),
              _buildField("Last Name", lastNameController, Icons.person_outline),
              _buildDropdown("Gender", ['Male', 'Female'], gender, (val) => setState(() => gender = val)),
              _buildDropdown("Marital Status", ['Single', 'Married', 'Divorced', 'Widowed'], maritalStatus, (val) => setState(() => maritalStatus = val)),
              _buildField("Phone", phoneController, Icons.phone),
              _buildField("Address", addressController, Icons.home),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: TextButton(
          onPressed: () async {
            try {
              String uid;

              if (passwordController.text.trim().isNotEmpty) {
                // Email/password flow
                UserCredential userCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );
                uid = userCredential.user!.uid;
              } else {
                // Google Sign-In flow
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  throw Exception("No signed-in Google user found.");
                }
                uid = user.uid;
              }

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userId', uid);

              // Save user to Firestore
              await FirebaseFirestore.instance.collection('users').doc(uid).set({
                'email': emailController.text,
                'firstName': firstNameController.text,
                'lastName': lastNameController.text,
                'gender': gender,
                'maritalStatus': maritalStatus,
                'phone': phoneController.text,
                'address': addressController.text,
                'role': 'Therapist',
                'createdAt': FieldValue.serverTimestamp(),
              });

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyAppFile()),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          },
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text("Confirm and Submit"),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.arrow_drop_down),
          border: const OutlineInputBorder(),
        ),
        items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        onChanged: (val) => onChanged(val!),
      ),
    );
  }
}
