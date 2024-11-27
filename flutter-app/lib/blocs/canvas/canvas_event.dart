import 'dart:ui';

import 'package:textify/models/text_item.dart';

abstract class CanvasEvent {
  const CanvasEvent();

  List<Object> get props => [];
}

class AddTextItem extends CanvasEvent {}

class UpdateTextItem extends CanvasEvent {
  final TextItem textItem;
  const UpdateTextItem(this.textItem);

  @override
  List<Object> get props => [textItem];
}

class DeleteTextItem extends CanvasEvent {
  final String id;
  const DeleteTextItem(this.id);

  @override
  List<Object> get props => [id];
}

class Undo extends CanvasEvent {}

class Redo extends CanvasEvent {}

class StartEditing extends CanvasEvent {
  final String itemId;
  final String content;
  final TextItem item;
  const StartEditing(this.itemId, this.content, this.item);

  @override
  List<Object> get props => [itemId, content];
}

class StopEditing extends CanvasEvent {
  final TextItem item;
  const StopEditing(this.item);

  @override
  List<Object> get props => [item];
}

class ChangeFontSize extends CanvasEvent {
  final int fontSize;

  ChangeFontSize(this.fontSize);

  @override
  List<Object> get props => [fontSize];
}

class ChangeColor extends CanvasEvent {
  final Color color;

  ChangeColor(this.color);

  @override
  List<Object> get props => [color];
}
