import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_core/firebase_core.dart';

import 'NextStepMain/aac_types.dart';
import 'shared_selection.dart';
import 'NextStepMain/top_input_bar.dart';
import 'NextStepMain/bottom_sentence_bar.dart';
import 'the_game.dart'; // ✅ Import the second component

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NextStepMainApp());
}

class NextStepMainApp extends StatelessWidget {
  const NextStepMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proloquo2Go Mock',
      theme: ThemeData(useMaterial3: true),
      home: const AacGridPage(),
    );
  }
}

class AacGridPage extends StatefulWidget {
  const AacGridPage({super.key});

  @override
  State<AacGridPage> createState() => _AacGridPageState();
}

class _AacGridPageState extends State<AacGridPage> {
  List<TileData> get _selected => SharedSelection.tiles;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tts..setLanguage('en-US')..setPitch(1.0);
  }

  List<TileData> _docsToTiles(QuerySnapshot snap) => snap.docs
      .map((doc) {
        final m = doc.data() as Map<String, dynamic>;
        try {
          return TileData(
            id: doc.id,
            text: (m['message'] ?? '').toString(),
            color: Color((m['color'] ?? 0xFFFFFFFF) as int),
            imageUrl: m['imageUrl'] as String?,
          );
        } catch (e) {
          log('Bad doc ${doc.id}: $e');
          return null;
        }
      })
      .whereType<TileData>()
      .toList();

  void _append(TileData t) {
    setState(() => _selected.add(t));
    _tts.speak(t.text);
  }

  void _pop() {
    setState(() {
      if (_selected.isNotEmpty) _selected.removeLast();
    });
  }

  void _goToCategoryBoxes(TileData t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Proloquo2GoMock(categoryId: t.id),
      ),
    ).then((_) => setState(() {})); 
      
  }

  void _clearAll() {
    setState(() => _selected.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Category'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear all',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          TopInputBar(
            selected: _selected,
            onRemoveLast: _pop,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final tiles = _docsToTiles(snap.data!);
                if (tiles.isEmpty) return const Center(child: Text('No boxes yet'));

                return GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  children: tiles.map((t) {
                    return AACButton(
                      data: t,
                      onTap: () {
                     
                        _goToCategoryBoxes(t); // ✅ Navigate after
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          BottomSentenceBar(selected: _selected),
        ],
      ),
    );
  }
}

class AACButton extends StatelessWidget {
  final TileData data;
  final VoidCallback onTap;
  const AACButton({required this.data, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          onTap();
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text(data.text)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: data.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 2),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (data.imageUrl != null)
                Expanded(child: Image.network(data.imageUrl!, fit: BoxFit.contain)),
              Text(data.text, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
