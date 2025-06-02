import 'package:flutter/material.dart';
import '../ApiConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: TherapistRegisterPage1(),
    debugShowCheckedModeBanner: false,
  ));
}

class TherapistRegisterPage1 extends StatefulWidget {
  const TherapistRegisterPage1({super.key});

  @override
  State<TherapistRegisterPage1> createState() => _TherapistRegisterPage1State();
}

class _TherapistRegisterPage1State extends State<TherapistRegisterPage1> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Therapist Registration"),
      ),
     body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const LinearProgressIndicator(
              value: 0.33,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              "Therapist",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("By signing up you are agreeing to our Terms and Privacy Policy"),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
               keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
             
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.remove_red_eye),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.remove_red_eye),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
           
          ],
        ),
      ),
       ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 10),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
        ),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TherapistRegisterPage2(
                  email: emailController.text,
                  password: passwordController.text,
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Therapist Registration"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const LinearProgressIndicator(
              value: 0.66,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              "Therapist",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("By signing up you are agreeing to our Terms and Privacy Policy"),
            const SizedBox(height: 24),

            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                
                prefixIcon: Icon(Icons.person),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                prefixIcon: Icon(Icons.person_outline),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: maritalStatus,
              decoration: const InputDecoration(
                labelText: 'Marital Status',
                prefixIcon: Icon(Icons.family_restroom),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Single', child: Text('Single')),
                DropdownMenuItem(value: 'Married', child: Text('Married')),
                DropdownMenuItem(value: 'Divorced', child: Text('Divorced')),
                DropdownMenuItem(value: 'Widowed', child: Text('Widowed')),
              ],
              onChanged: (value) {
                setState(() {
                  maritalStatus = value!;
                });
              },
            ),

            const SizedBox(height: 80), // Extra space to prevent overlap
          ],
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 10),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
        ),
        child: TextButton(
          onPressed: () {
            // You can pass these new fields to the next page if needed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TherapistRegisterPage3(
                  // you might need to update this page constructor for these new fields
                  // For now just passing gender and marital status for example
                  email: '',       // empty or update accordingly
                  password: '',    // empty or update accordingly
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
    required this.maritalStatus,
    required this.gender,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // Navigate back to the previous screen
          },
        ),
        title: const Text("Contact Info"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             const LinearProgressIndicator(
              value: 1,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text("Contact Info", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
             TextField(
              controller: phoneController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.remove_red_eye),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
             const SizedBox(height: 20), // Extra space to prevent overlap
            TextField(
              controller: addressController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.remove_red_eye),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),

            const Spacer(),
           ElevatedButton(
            onPressed: () async {
          try {
             print("=== Therapist Registration Data ===");
            final response = await http.post(
              Uri.parse(ApiConfig.registerRoute), // Use the correct endpoint for registration
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': widget.email,
                'password': widget.password,
                'firstName': widget.firstName,
                'lastName': widget.lastName,
                'gender': widget.gender,
                'phone': "+1234567890",
                'address': addressController.text,
              }),
            );

            if (response.statusCode == 201) {
              // Handle success response
              print('Registration successful');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            } else {
              // Handle error response
              print('Registration failed: ${response.body}');
            }
          } catch (e) {
            // Handle exceptions
            print('Error: $e');
          }
        },
        style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        child: const Text("Submit"),
      ),
                ],
              ),
            ),
          );
        }
      }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Therapist Home")),
      body: const Center(
        child: Text("Welcome to the Therapist Home Page!", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
