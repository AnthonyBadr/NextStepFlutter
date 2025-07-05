import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'NextStepMain/aac_types.dart';
import 'shared_selection.dart';
import 'NextStepMain/top_input_bar.dart';
import 'NextStepMain/bottom_sentence_bar.dart';

class Proloquo2GoMock extends StatefulWidget {
  final String categoryId;
  const Proloquo2GoMock({required this.categoryId, super.key});

  @override
  State<Proloquo2GoMock> createState() => _Proloquo2GoMockState();
}

class _Proloquo2GoMockState extends State<Proloquo2GoMock> {
  List<TileData> get _selected => SharedSelection.tiles;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tts..setLanguage('en-US')..setPitch(1.0);
  }

  void _append(TileData t) {
    setState(() => _selected.add(t));
    _tts.speak(t.text);
  }

  void _pop() {
    setState(() {
      if (_selected.isNotEmpty) _selected.removeLast();
    });
  }

  void _clearAll() {
    setState(() => _selected.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
     
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), 
          // ✅ return a result
        ),
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
                  .doc(widget.categoryId)
                  .collection('boxes')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No boxes yet.'));
                }

                final tiles = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return TileData(
                    id: doc.id,
                    text: data['message'] ?? '',
                    color: Color((data['color'] ?? 0xFFFFFFFF) as int),
                    imageUrl: data['imageUrl'],
                  );
                }).toList();

                return GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  children: tiles
                      .map((t) => AACButton(data: t, onTap: () => _append(t)))
                      .toList(),
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text(data.text)));
      },
      borderRadius: BorderRadius.circular(8),
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
}
