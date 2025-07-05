import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(home: CreateBoxPage(), debugShowCheckedModeBanner: false),
  );
}

class CategoryData {
  final String id;
  final String name;
  CategoryData(this.id, this.name);
}

class CreateBoxPage extends StatefulWidget {
  @override
  State<CreateBoxPage> createState() => _CreateBoxPageState();
}

class _CreateBoxPageState extends State<CreateBoxPage> {
  final TextEditingController messageController = TextEditingController();
  File? selectedImage;
  Color selectedColor = Colors.blueAccent;

  List<CategoryData> _categories = [];
  CategoryData? _selectedCategory;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /* ─────────────────── Firestore: fetch categories ─────────────────── */
  Future<void> _loadCategories() async {
    final snap = await FirebaseFirestore.instance
        .collection('categories')       // ← adjust if your root path differs
        .orderBy('createdAt')
        .get();

    final cats = snap.docs
        .map((d) => CategoryData(d.id, (d['name'] ?? '').toString()))
        .toList();

    if (mounted) {
      setState(() {
        _categories = cats;
        _selectedCategory = cats.isNotEmpty ? cats.first : null;
      });
    }
  }

  /* ─────────────────── pickers ─────────────────── */
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => selectedImage = File(picked.path));
  }

  Future<void> pickColor() async {
    final palette = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.black,
      Colors.white,
    ];

    final Color? chosen = await showDialog<Color>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a color'),
        content: Wrap(
          spacing: 8,
          children: palette
              .map((c) => GestureDetector(
                    onTap: () => Navigator.pop(context, c),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
    if (chosen != null) setState(() => selectedColor = chosen);
  }

  /* ─────────────────── save box under category/{id}/boxes ─────────────────── */
  Future<void> saveBox() async {
    if (messageController.text.trim().isEmpty || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message & image required')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No category selected')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      // upload image
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('boxes/$fileName'); // keeping same bucket folder
      await ref.putFile(selectedImage!);
      final imageUrl = await ref.getDownloadURL();

      // add box under category sub-collection
      await FirebaseFirestore.instance
          .collection('categories')                  // ← parent
          .doc(_selectedCategory!.id)                // ← chosen category doc
          .collection('boxes')                       // ← sub-collection
          .add({
        'message': messageController.text.trim(),
        'color': selectedColor.value,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Box saved!')),
      );

      setState(() {
        messageController.clear();
        selectedImage = null;
        selectedColor = Colors.blueAccent;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  /* ─────────────────── UI ─────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Box'), backgroundColor: Colors.black87),
      body: _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: messageController,
                      decoration: const InputDecoration(labelText: 'Enter message'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CategoryData>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c.name)))
                          .toList(),
                      onChanged: (c) => setState(() => _selectedCategory = c),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Image'),
                        ),
                        const SizedBox(width: 12),
                        if (selectedImage != null)
                          Image.file(selectedImage!, width: 60, height: 60),
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
                    const Text('Preview:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          if (selectedImage != null)
                            Image.file(selectedImage!, height: 80),
                          Text(messageController.text,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_selectedCategory?.name ?? ''),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saving ? null : saveBox,
        icon: saving
            ? const SizedBox(
                width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.save),
        label: saving ? const Text('Saving...') : const Text('Save Box'),
      ),
    );
  }
}
