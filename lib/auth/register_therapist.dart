import 'dart:convert'; // Import this for JSON encoding
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/auth/components/StepSlider.dart'; // Import the StepSlider component

class Therapist_Register extends StatefulWidget {
  const Therapist_Register({Key? key}) : super(key: key);

  @override
  _TherapistRegisterState createState() => _TherapistRegisterState();
}

class _TherapistRegisterState extends State<Therapist_Register> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers for form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _maritalStatusController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _cvController = TextEditingController();
  final TextEditingController _extraCertificatesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Therapist Register')),
      body: Column(
        children: [
          // Use the StepSlider component
          StepSlider(
            currentStep: _currentPage,
            totalSteps: 4, // Total number of steps
          ),
          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Step 1: Personal Information
                _buildStep(
                  title: 'Personal Information',
                  fields: [
                    _buildTextField(controller: _firstNameController, label: 'First Name'),
                    _buildTextField(controller: _lastNameController, label: 'Last Name'),
                    _buildDatePicker(controller: _dobController, label: 'Date of Birth'),
                    _buildTextField(controller: _genderController, label: 'Gender'),
                    _buildTextField(controller: _maritalStatusController, label: 'Marital Status'),
                  ],
                  onNext: () {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                  },
                ),
                // Step 2: Contact Information
                _buildStep(
                  title: 'Contact Information',
                  fields: [
                    _buildTextField(controller: _emailController, label: 'Email'),
                    _buildTextField(controller: _passwordController, label: 'Password', obscureText: true),
                    _buildTextField(controller: _titleController, label: 'Title (Dr)'),
                  ],
                  onNext: () {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                  },
                ),
                // Step 3: Qualifications
                _buildStep(
                  title: 'Qualifications',
                  fields: [
                    _buildTextField(controller: _certificateController, label: 'Certificate to prove you\'re a Therapist'),
                    _buildTextField(controller: _universityController, label: 'Graduated University'),
                    _buildTextField(controller: _cvController, label: 'CV'),
                  ],
                  onNext: () {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                  },
                ),
                // Step 4: Additional Certifications
                _buildStep(
                  title: 'Additional Certifications',
                  fields: [
                    _buildTextField(controller: _extraCertificatesController, label: 'Extra Certificates'),
                  ],
                  onNext: () {
                    // Final submit, process the form
                    _submitForm();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build form steps
  Widget _buildStep({
    required String title,
    required List<Widget> fields,
    required VoidCallback onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          ...fields,
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onNext,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  // Helper method to create text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  // Helper method to create date picker
  Widget _buildDatePicker({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }

  // Method to convert the form data to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'dob': _dobController.text,
      'gender': _genderController.text,
      'marital_status': _maritalStatusController.text,
      'email': _emailController.text,
      'title': _titleController.text,
      'certificate': _certificateController.text,
      'university': _universityController.text,
      'cv': _cvController.text,
      'extra_certificates': _extraCertificatesController.text,
    };
  }

  // Final submit method
  void _submitForm() {

    //Put the api 


    // Print form data in JSON format in the console
    String jsonData = jsonEncode(toJson()); // Get JSON data here
    print('Form Data in JSON format: $jsonData');
  }
}
