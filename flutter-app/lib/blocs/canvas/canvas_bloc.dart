import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:textify/models/text_item.dart';
import 'package:logger/logger.dart';
import 'canvas_event.dart';
import 'canvas_state.dart';

class CanvasBloc extends Bloc<CanvasEvent, CanvasState> {
  CanvasBloc() : super(CanvasState()) {
    on<AddTextItem>(_onAddTextItem);
    on<UpdateTextItem>(_onUpdateTextItem);
    on<DeleteTextItem>(_onDeleteTextItem);
    on<Undo>(_onUndo);
    on<Redo>(_onRedo);
  }

  void _onAddTextItem(AddTextItem event, Emitter<CanvasState> emit) {
    final newItem = TextItem(
      id: DateTime.now().toString().replaceAll(RegExp('[^0-9]'), ''),
      content: '',
      fontSize: 16,
      color: '#000000',
    );

    emit(state.copyWith(
      textItems: List.from(state.textItems)..add(newItem),
      undoStack: List.from(state.undoStack)..add(state.textItems),
    ));
    startEditing(newItem.id, newItem.content, newItem);
  }

  void _onUpdateTextItem(UpdateTextItem event, Emitter<CanvasState> emit) {
    final updatedItems = state.textItems.map((item) {
      return item.id == event.textItem.id ? event.textItem : item;
    }).toList();

    emit(state.copyWith(
      textItems: updatedItems,
      undoStack: List.from(state.undoStack)..add(state.textItems),
      editingItemId: state.editingItemId,
      selectedItemId: state.selectedItemId,
    ));
  }

  void _onDeleteTextItem(DeleteTextItem event, Emitter<CanvasState> emit) {
    final updatedItems = state.textItems.where((item) => item.id != event.id).toList();

    emit(state.copyWith(
      textItems: updatedItems,
      undoStack: List.from(state.undoStack)..add(state.textItems),
      editingItemId: null,
      selectedItemId: null,
      editingItem: null,
      selectedItem: null,
    ));
  }

  void _onUndo(Undo event, Emitter<CanvasState> emit) {
    if (state.undoStack.isNotEmpty) {
      final lastState = state.undoStack.last;
      emit(state.copyWith(
        textItems: lastState,
        undoStack: List.from(state.undoStack)..removeLast(),
        redoStack: List.from(state.redoStack)..add(state.textItems),
      ));
    }
  }

  void _onRedo(Redo event, Emitter<CanvasState> emit) {
    if (state.redoStack.isNotEmpty) {
      final nextState = state.redoStack.last;
      emit(state.copyWith(
        textItems: nextState,
        redoStack: List.from(state.redoStack)..removeLast(),
        undoStack: List.from(state.undoStack)..add(state.textItems),
      ));
    }
  }

  void exportCanvas(GlobalKey globalKey) async {
    // Export canvas logic
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = (await getApplicationDocumentsDirectory()).path;
      final imgFile = File('$directory/canvas_export.png');
      await imgFile.writeAsBytes(pngBytes);

      // Share the exported file
      // You can use the 'share' package to share the file
      // Add the 'share' package to your pubspec.yaml file
      // import 'package:share/share.dart';
      await Share.shareXFiles([
        XFile(imgFile.path)
      ], text: 'Check out my canvas!');

      emit(state.copyWith(exportSuccess: true));
    } catch (e) {
      Logger().e("Error exporting canvas $e");
      emit(state.copyWith(exportSuccess: false));
    }
  }

  void startEditing(String itemId, String content, TextItem item) {
    emit(state.copyWith(
      editingItemId: itemId,
      editingItem: item,
      selectedItem: null,
      selectedItemId: null,
    ));
  }

  void stopEditing(TextItem? item) {
    if (item != null) {
      add(UpdateTextItem(item));
    }
    emit(
      state.copyWith(
        editingItemId: null,
        editingItem: null,
        selectedItem: null,
        selectedItemId: null,
      ),
    );
  }

  void selectItem(TextItem item) {
    emit(state.copyWith(
      selectedItemId: item.id,
      selectedItem: item,
      editingItemId: null,
      editingItem: null,
    ));
  }

  void unselectItem() {
    emit(state.copyWith(
      selectedItemId: null,
      selectedItem: null,
      editingItem: null,
      editingItemId: null,
    ));
  }
}
