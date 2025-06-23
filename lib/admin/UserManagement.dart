import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ApiConfig.dart'; // Update this path to your actual config file

void main() {
  runApp(const MaterialApp(
    home: UserListPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class User {
  final String firstName;
  final String lastName;
  final String role;
  final String id;
  final String email;
  final String password;
  final String gender;
  final String address;

  User({
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.id,
    required this.email,
    required this.password,
    required this.gender,
    required this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User> users = [];
  List<User> filteredUsers = [];
  bool isLoading = true;
  bool showFilterPanel = false;

  String selectedRole = 'All';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.GetAllUsers));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          users = jsonData.map((item) => User.fromJson(item)).toList();
          filteredUsers = List.from(users);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void applyFilters() {
    setState(() {
      filteredUsers = users.where((user) {
        return selectedRole == 'All' ||
            user.role.toLowerCase() == selectedRole.toLowerCase();
      }).toList();
      showFilterPanel = false;
    });
  }

  Widget buildFilterPanel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: showFilterPanel ? 0 : -250,
      top: 0,
      bottom: 0,
      width: 250,
      child: Material(
        elevation: 4,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Roles')),
                  DropdownMenuItem(value: 'patient', child: Text('Patient')),
                  DropdownMenuItem(value: 'therapist', child: Text('Therapist')),
                  DropdownMenuItem(value: 'special educator', child: Text('Special Educator')),
                  DropdownMenuItem(value: 'parent', child: Text('Parent')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: applyFilters,
                child: const Text("Apply"),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserRow(User user) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailPage(user: user)),
        ).then((updated) {
          if (updated == true) fetchUsers();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(user.firstName, overflow: TextOverflow.ellipsis)),
            Expanded(child: Text(user.lastName, overflow: TextOverflow.ellipsis)),
            Expanded(child: Text(user.role, style: const TextStyle(color: Colors.blue), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        leading: IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => setState(() => showFilterPanel = !showFilterPanel),
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: const [
                            Expanded(child: Text("First Name", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Text("Last Name", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(child: Text("Role", style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) => buildUserRow(filteredUsers[index]),
                        ),
                      ),
                    ],
                  ),
                ),
          buildFilterPanel(),
        ],
      ),
    );
  }
}

class UserDetailPage extends StatefulWidget {
  final User user;

  const UserDetailPage({super.key, required this.user});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController genderController;
  late TextEditingController addressController;
  late TextEditingController roleController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    emailController = TextEditingController(text: widget.user.email);
    genderController = TextEditingController(text: widget.user.gender);
    addressController = TextEditingController(text: widget.user.address);
    roleController = TextEditingController(text: widget.user.role);
  }

  Future<void> updateUser() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/UpdateUserById/users/${widget.user.id}");

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': emailController.text,
        'gender': genderController.text,
        'address': addressController.text,
        'role': roleController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
      Navigator.pop(context, true); // Pop and return success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.user.firstName} ${widget.user.lastName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
            TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: genderController, decoration: const InputDecoration(labelText: 'Gender')),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Role')),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: updateUser,
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Delete not implemented')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}