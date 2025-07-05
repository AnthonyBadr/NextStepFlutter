import 'package:flutter/material.dart';

class TileData {
    final String id; // <--- Add this
  final String text;
  final Color color;
  final String? imageUrl;

  const TileData({
    required this.id,
    required this.text,
    required this.color,
    this.imageUrl,
  });
}
