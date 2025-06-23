import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  Future<Map<String, dynamic>?> getTherapistById(String docId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getTherapistById("eyE1Qew6X58k6NR63sjh"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("❌ Error loading therapist"));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No therapist found."));
        }

        final data = snapshot.data!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text("Therapist Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            "Welcome Dr ${data['firstName']} ${data['lastName']}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text("Email: ${data['email']}", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );

      },
    );
  }
}
