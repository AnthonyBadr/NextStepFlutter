import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

// Make sure this import path is correct for your project
import 'package:my_app/homepage/pageorg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const MyAppFile());
}

class MyAppFile extends StatelessWidget {
  const MyAppFile({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadScreen(),
    );
  }
}

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? cvFile;
  String? cvFileName;
  List<File> certificationFiles = [];
  List<String> certificationNames = [];
  String status = '';
  bool isUploading = false;

  Future selectCV() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      cvFile = File(result.files.single.path!);
      cvFileName = result.files.single.name;
    });
  }

  Future selectCertifications() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    setState(() {
      certificationFiles = result.paths.map((path) => File(path!)).toList();
      certificationNames = result.names.map((name) => name ?? '').toList();
    });
  }

  Future uploadFiles() async {
    if (cvFile == null && certificationFiles.isEmpty) return;

    setState(() {
      isUploading = true;
      status = 'Uploading...';
    });

    try {
      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;

      // Upload CV
      if (cvFile != null) {
        final ref = storage.ref().child('cv/$cvFileName');
        await ref.putFile(cvFile!);
        final url = await ref.getDownloadURL();
        await firestore.collection('files').add({
          'type': 'cv',
          'name': cvFileName,
          'url': url,
          'uploadedAt': Timestamp.now(),
        });
      }

      // Upload certifications
      for (int i = 0; i < certificationFiles.length; i++) {
        final certFile = certificationFiles[i];
        final certName = certificationNames[i];
        final ref = storage.ref().child('certifications/$certName');
        await ref.putFile(certFile);
        final url = await ref.getDownloadURL();
        await firestore.collection('files').add({
          'type': 'certification',
          'name': certName,
          'url': url,
          'uploadedAt': Timestamp.now(),
        });
      }

      setState(() {
        status = '✅ All files uploaded successfully!';
        isUploading = false;
      });

      // Navigate to home page after upload
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyScreen()), // or your actual HomePage
      );
    } catch (e) {
      setState(() {
        status = '❌ Upload failed: $e';
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Documents'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Upload Your CV", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: selectCV,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Select CV"),
                      ),
                      const SizedBox(height: 8),
                      if (cvFileName != null)
                        Text("📄 Selected: $cvFileName", style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Upload Certifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: selectCertifications,
                        icon: const Icon(Icons.attach_file),
                        label: const Text("Select Files"),
                      ),
                      const SizedBox(height: 8),
                      if (certificationNames.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: certificationNames
                              .map((name) => Text("📎 $name", style: const TextStyle(fontSize: 14)))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: isUploading ? null : uploadFiles,
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Upload All"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                status,
                style: TextStyle(
                  color: status.startsWith('✅')
                      ? Colors.green
                      : status.startsWith('❌')
                          ? Colors.red
                          : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
