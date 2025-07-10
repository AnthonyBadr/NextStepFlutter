import 'package:flutter/material.dart';
import 'package:my_app/admin/UserManagement.dart'; // Remove if unused
import 'package:my_app/homepage/pageorg.dart';
import 'package:my_app/homepage/the_game.dart';
import 'package:my_app/sharedpreferences/shared_pref.dart';
import 'package:my_app/auth/confirmemail.dart';
import 'package:my_app/auth/login_page.dart';
import 'package:my_app/auth/test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/auth/register_therapist.dart';

class PickRolePage extends StatelessWidget {
  const PickRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          top: true,
          bottom: false, // Removes bottom padding that causes white bar
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Logo
                Container(
                  height: 100,
                  width: 100,
                  margin: const EdgeInsets.symmetric(vertical: 16),
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
                const SizedBox(height: 24),

                // GridView of roles
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 3 / 3.2,
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

                const SizedBox(height: 24),

                // Join Team Button
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Join team action coming soon!')),
                    );
                  },
                  child: const Text(
                    'To join the Next Step team, click here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _selectRole(context, title.toLowerCase()),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
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
    print('Selected Role: $role');

    if (role == "therapist") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  TherapistRegisterPage1()),
      );
    } else if (role == "patient") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
  }
}
