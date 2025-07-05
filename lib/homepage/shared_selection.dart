// shared_selection.dart
import 'NextStepMain/aac_types.dart';

/// A global shared list of selected tiles.
/// This allows all pages to access and modify the same selection.
class SharedSelection {
  static final List<TileData> tiles = <TileData>[];
}
