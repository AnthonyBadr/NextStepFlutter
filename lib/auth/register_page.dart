import 'package:flutter/material.dart';
import 'register_therapist.dart'; // Import the Therapist_Register page

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      print('User Data: $userData'); // Print data for debugging

      // Navigate to the Therapist_Register page, passing the user data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Therapist_Register(userData: userData), // Pass data to the next page
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Dummy Logo
              Image.asset(
                'assets/logo.png', // Ensure you have a logo in the assets folder
                height: 100,
              ),
              const SizedBox(height: 20),

              _buildTextField('First Name', _firstNameController),
              const SizedBox(height: 10),

              _buildTextField('Last Name', _lastNameController),
              const SizedBox(height: 10),

              _buildTextField('Email', _emailController, emailValidator: true),
              const SizedBox(height: 10),

              _buildTextField('Password', _passwordController, obscureText: true, passwordValidator: true),
              const SizedBox(height: 20),

              // Register Button
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, bool emailValidator = false, bool passwordValidator = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (emailValidator && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Enter a valid email';
        }
        if (passwordValidator && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}
