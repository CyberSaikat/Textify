import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:textify/blocs/canvas/canvas_state.dart';
import '../models/text_item.dart';
import '../blocs/canvas/canvas_bloc.dart';
import '../blocs/canvas/canvas_event.dart';

class ToolbarWidget extends StatelessWidget {
  const ToolbarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasBloc, CanvasState>(
      builder: (context, state) {
        if (state.textItems.isEmpty) {
          return const SizedBox.shrink();
        } else if (state.editingItemId != null && state.textItems.isNotEmpty) {
          final textItem = state.textItems.firstWhere((item) => item.id == state.editingItemId);
          return _buildToolbar(context, textItem, true);
        } else if (state.selectedItemId != null && state.textItems.isNotEmpty) {
          final textItem = state.textItems.firstWhere((item) => item.id == state.selectedItemId);
          return _buildToolbar(context, textItem, true);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildToolbar(BuildContext context, TextItem? textItem, bool isEditing) {
    const Map<String, Color> colorMap = {
      "Black": Colors.black,
      "Red": Colors.red,
      "Green": Colors.green,
      "Blue": Colors.blue,
    };
    return Visibility(
      visible: isEditing,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Font Dropdown
              DropdownButton<String>(
                value: textItem!.fontFamily,
                items: [
                  "Arial",
                  "Roboto",
                  "Times New Roman",
                  "Verdana",
                ]
                    .map((font) => DropdownMenuItem(
                          value: font,
                          child: Text(font),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<CanvasBloc>().add(
                          UpdateTextItem(textItem.copyWith(fontFamily: value)),
                        );
                  }
                },
                hint: const Text("Font"),
              ),
              const SizedBox(width: 8),
              // Font Size Dropdown
              DropdownButton<int>(
                value: textItem.fontSize,
                items: [
                  12,
                  14,
                  16,
                  18,
                  20,
                  24,
                  28,
                  32,
                ]
                    .map((size) => DropdownMenuItem(
                          value: size,
                          child: Text(size.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<CanvasBloc>().add(
                          UpdateTextItem(textItem.copyWith(fontSize: value)),
                        );
                  }
                },
                hint: const Text("Font Size"),
              ),
              const SizedBox(width: 8),

              // Bold Button
              IconButton(
                onPressed: () {
                  context.read<CanvasBloc>().add(
                        UpdateTextItem(
                          textItem.copyWith(isBold: !textItem.isBold),
                        ),
                      );
                },
                icon: const Icon(Icons.format_bold),
                color: textItem.isBold ? Colors.blue : Colors.black,
              ),
              const SizedBox(width: 8),

              // Italic Button
              IconButton(
                onPressed: () {
                  context.read<CanvasBloc>().add(
                        UpdateTextItem(
                          textItem.copyWith(isItalic: !textItem.isItalic),
                        ),
                      );
                },
                icon: const Icon(Icons.format_italic),
                color: textItem.isItalic ? Colors.blue : Colors.black,
              ),
              const SizedBox(width: 8),

              // Underline Button
              IconButton(
                onPressed: () {
                  context.read<CanvasBloc>().add(
                        UpdateTextItem(
                          textItem.copyWith(isUnderline: !textItem.isUnderline),
                        ),
                      );
                },
                icon: const Icon(Icons.format_underline),
                color: textItem.isUnderline ? Colors.blue : Colors.black,
              ),
              const SizedBox(width: 8),

              DropdownButton(
                value: textItem.color,
                items: colorMap.keys
                    .map((color) => DropdownMenuItem(
                          value: '#${colorMap[color]!.value.toRadixString(16).substring(2)}',
                          child: Text(color),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<CanvasBloc>().add(
                          UpdateTextItem(textItem.copyWith(color: value)),
                        );
                  }
                },
                hint: const Text("Color"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
