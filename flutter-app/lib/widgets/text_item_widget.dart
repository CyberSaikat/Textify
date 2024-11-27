import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:textify/models/text_item.dart';
import '../blocs/canvas/canvas_bloc.dart';
import '../blocs/canvas/canvas_event.dart';

class TextItemWidget extends StatefulWidget {
  final TextItem textItem;
  final bool isEditing;
  final bool isSelected;

  const TextItemWidget({super.key, required this.textItem, required this.isEditing, required this.isSelected});

  @override
  State<TextItemWidget> createState() => _TextItemWidgetState();
}

class _TextItemWidgetState extends State<TextItemWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.textItem.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void stopEditing(BuildContext context) {
    TextItem textItem = widget.textItem.copyWith(content: _controller.text);
    context.read<CanvasBloc>().stopEditing(textItem);
  }

  @override
  Widget build(BuildContext context) {
    final textItem = widget.textItem;

    return Positioned(
      left: textItem.x,
      top: textItem.y,
      child: Draggable(
        onDragEnd: (details) {
          context.read<CanvasBloc>().add(
                UpdateTextItem(
                  textItem.copyWith(x: details.offset.dx, y: details.offset.dy),
                ),
              );
        },
        feedback: Material(
          color: Colors.transparent,
          child: Text(
            textItem.content,
            style: TextStyle(fontSize: textItem.fontSize.toDouble()),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onDoubleTap: () {
              context.read<CanvasBloc>().startEditing(textItem.id, textItem.content, textItem);
            },
            onTap: () {
              if (widget.isEditing) {
                return;
              }
              context.read<CanvasBloc>().selectItem(textItem);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.isSelected ? Colors.blue : Colors.transparent,
                ),
              ),
              child: widget.isEditing
                  ? SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(
                          fontSize: textItem.fontSize.toDouble(),
                          decoration: textItem.isUnderline ? TextDecoration.underline : TextDecoration.none,
                          fontWeight: textItem.isBold ? FontWeight.bold : FontWeight.normal,
                          fontStyle: textItem.isItalic ? FontStyle.italic : FontStyle.normal,
                          fontFamily: textItem.fontFamily,
                          color: Color(
                            int.parse(
                              textItem.color.replaceAll('#', '0xFF'),
                            ),
                          ),
                        ),
                        onSubmitted: (_) => stopEditing(context),
                        onEditingComplete: () => stopEditing(context),
                      ),
                    )
                  : Text(
                      textItem.content,
                      style: TextStyle(
                        fontSize: textItem.fontSize.toDouble(),
                        decoration: textItem.isUnderline ? TextDecoration.underline : TextDecoration.none,
                        fontWeight: textItem.isBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle: textItem.isItalic ? FontStyle.italic : FontStyle.normal,
                        fontFamily: textItem.fontFamily,
                        color: Color(
                          int.parse(
                            textItem.color.replaceAll('#', '0xFF'),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
