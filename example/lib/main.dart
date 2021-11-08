import 'package:flutter/material.dart';
import 'package:rich_field_controller/rich_field_controller.dart';
import 'package:reditor_example/selection_controls.dart';
import 'package:reditor_example/toolbar.dart';

/// This example illustrates how to use a [RichTextController] with a [TextField]
/// to turn it into a rich text input field
void main() {
  runApp(const ReditorExample());
}

class ReditorExample extends StatelessWidget {
  const ReditorExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final FocusNode _fieldNode;
  late final RichFieldController _controller;
  // This is for demonstration only. You can define your own [TextSelectionControl]
  // and inject a [RichFieldController] in it to access the styling properties
  late final RichFieldSelectionControls _selectionControls;

  @override
  void initState() {
    super.initState();
    _fieldNode = FocusNode();
    _controller = RichFieldController(_fieldNode);
    _selectionControls = RichFieldSelectionControls(context, _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _fieldNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ReditorToolBarExample(
              onAction: (textStyle) {
                // If we want to keep the text selected after styling
                _controller.selection = _controller.paragraph.selection;
                // Apply [textStyle] to the paragraph's selection
                _controller.paragraph.updateActiveElementStyle(textStyle);
              },
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.teal[200]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _fieldNode,
                  maxLines: null,

                  // Use the style property to set a default style
                  style: const TextStyle(fontSize: 18, height: 1.75, color: Colors.black87),
                  selectionControls: _selectionControls,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Write something here...',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Handles the formatting options that show on text selection
/// when a left clicking on a text
///
