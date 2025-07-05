import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: CreateCategoryPage(), debugShowCheckedModeBanner: false));
}

class CreateCategoryPage extends StatefulWidget {
  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final TextEditingController nameController = TextEditingController();
  File? selectedImage;
  Color selectedColor = Colors.blueAccent;
  bool saving = false;

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<void> pickColor() async {
    Color? picked = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: Wrap(
          spacing: 8,
          children: [
            ...[
              Colors.red, Colors.green, Colors.blue, Colors.orange,
              Colors.purple, Colors.pink, Colors.teal, Colors.black, Colors.white,
            ].map((color) => GestureDetector(
                  onTap: () => Navigator.of(context).pop(color),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (picked != null) {
      setState(() => selectedColor = picked);
    }
  }

  Future<void> saveCategory() async {
    if (nameController.text.trim().isEmpty || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category name and image are required')));
      return;
    }

    setState(() => saving = true);

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('categories/$fileName');
      await ref.putFile(selectedImage!);
      final imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('categories').add({
        'name': nameController.text.trim(),
        'color': selectedColor.value,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Category created!')));

      setState(() {
        nameController.clear();
        selectedImage = null;
        selectedColor = Colors.blueAccent;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Category'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Icon'),
                  ),
                  const SizedBox(width: 12),
                  if (selectedImage != null)
                    Image.file(selectedImage!, width: 60, height: 60, fit: BoxFit.cover),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: pickColor,
                    icon: const Icon(Icons.color_lens),
                    label: const Text('Pick Color'),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 30, height: 30, color: selectedColor),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text('Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (selectedImage != null)
                      Image.file(selectedImage!, width: 40, height: 40),
                    const SizedBox(width: 10),
                    Text(
                      nameController.text,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saving ? null : saveCategory,
        icon: saving
            ? const SizedBox(
                width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.save),
        label: saving ? const Text('Saving...') : const Text('Save Category'),
      ),
    );
  }
}
