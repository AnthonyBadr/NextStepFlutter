import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/auth/register_therapist.dart';
class PickRolePage extends StatelessWidget {
  const PickRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Role'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Container(
                  height: 120,
                  width: 120,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.psychology_alt,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),

                // Welcome Text
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please select your role to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Role Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildRoleCard(
                      context,
                      'Parent',
                      Icons.family_restroom,
                      Colors.blue,
                      'Monitor and support your child\'s progress',
                    ),
                    _buildRoleCard(
                      context,
                      'Therapist',
                      Icons.medical_services,
                      Colors.green,
                      'Provide professional therapy services',
                    ),
                    _buildRoleCard(
                      context,
                      'Patient',
                      Icons.person,
                      Colors.orange,
                      'Access your therapy resources',
                    ),
                    _buildRoleCard(
                      context,
                      'Special Educator',
                      Icons.school,
                      Colors.purple,
                      'Provide specialized education',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, IconData icon,
      Color color, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _selectRole(context, title.toLowerCase()), // Pass context here
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectRole(BuildContext context, String role) async {
    print('Selected Role: $role'); // Log the selected role
    if (role == "therapist") {
      // Navigate to the Therapist_Register page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  TherapistRegisterPage1()),
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role); // Store the role
  }
}
