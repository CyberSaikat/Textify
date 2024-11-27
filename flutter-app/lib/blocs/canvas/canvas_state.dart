import 'package:textify/models/text_item.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<List<TextItem>> undoStack;
  final List<List<TextItem>> redoStack;
  final String? editingItemId;
  final TextItem? editingItem;
  final String? selectedItemId;
  final TextItem? selectedItem;
  final bool? exportSuccess;

  CanvasState({
    this.textItems = const [],
    this.undoStack = const [],
    this.redoStack = const [],
    this.editingItemId = '',
    this.editingItem,
    this.selectedItemId,
    this.selectedItem,
    this.exportSuccess,
  });

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<List<TextItem>>? undoStack,
    List<List<TextItem>>? redoStack,
    String? editingItemId,
    TextItem? editingItem,
    String? selectedItemId,
    TextItem? selectedItem,
    bool? exportSuccess,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      editingItemId: editingItemId,
      editingItem: editingItem,
      selectedItemId: selectedItemId,
      selectedItem: selectedItem,
      exportSuccess: exportSuccess,
    );
  }
}
