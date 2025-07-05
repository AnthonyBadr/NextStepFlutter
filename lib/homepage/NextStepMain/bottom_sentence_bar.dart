import 'package:flutter/material.dart';
import 'aac_types.dart'; // Make sure this file defines the TileData class

class TopInputBar extends StatelessWidget {
  final List<TileData> selected;
  final VoidCallback onRemoveLast;

  const TopInputBar({
    super.key,
    required this.selected,
    required this.onRemoveLast,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'Remove last',
              onPressed: selected.isEmpty ? null : onRemoveLast,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  children: selected
                      .map((t) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _TileThumb(t),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileThumb extends StatelessWidget {
  final TileData data;
  const _TileThumb(this.data);

  @override
  Widget build(BuildContext context) {
    const double size = 40;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black54),
      ),
      child: data.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                data.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined, size: 18),
              ),
            )
          : Center(
              child: Text(
                data.text,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
