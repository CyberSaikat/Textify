import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:textify/widgets/text_item_widget.dart';
import 'package:textify/widgets/toolbar_widget.dart';
import '../blocs/canvas/canvas_bloc.dart';
import '../blocs/canvas/canvas_event.dart';
import '../blocs/canvas/canvas_state.dart';

class TextCanvasScreen extends StatefulWidget {
  const TextCanvasScreen({super.key});

  @override
  State<TextCanvasScreen> createState() => _TextCanvasScreenState();
}

class _TextCanvasScreenState extends State<TextCanvasScreen> {
  final GlobalKey _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        title: const Text("Textify"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<CanvasBloc>().add(AddTextItem());
            },
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              context.read<CanvasBloc>().add(Undo());
            },
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () {
              context.read<CanvasBloc>().add(Redo());
            },
          ),
          BlocBuilder<CanvasBloc, CanvasState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.delete),
                onPressed: state.editingItemId != null || state.selectedItemId != null
                    ? () {
                        context.read<CanvasBloc>().add(
                              DeleteTextItem(state.editingItemId ?? state.selectedItemId!),
                            );
                      }
                    : null,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<CanvasBloc, CanvasState>(
        builder: (context, state) {
          return Container(
            height: 50,
            color: Colors.black54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.textItems.length,
              itemBuilder: (context, index) {
                final item = state.textItems[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CanvasBloc>().startEditing(item.id, item.content, item);
                    },
                    child: Text(item.content),
                  ),
                );
              },
            ),
          );
        },
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ToolbarWidget(),
          ),
          const SizedBox(height: 10),
          const Text(
            "Double tap on a text item to edit it",
            style: TextStyle(fontSize: 16),
          ),
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: GestureDetector(
                onTap: () {
                  context.read<CanvasBloc>().stopEditing(null);
                  context.read<CanvasBloc>().unselectItem();
                },
                child: BlocBuilder<CanvasBloc, CanvasState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.8,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: GestureDetector(
                          child: Stack(
                            children: state.textItems.map((item) {
                              return TextItemWidget(
                                textItem: item,
                                isEditing: state.editingItemId == item.id,
                                isSelected: state.selectedItemId == item.id,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
