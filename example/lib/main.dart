import 'package:flutter/material.dart';
import 'package:rich_field_controller/rich_field_controller.dart';
import './toolbar.dart';

/// This example illustrates how to use a [RichTextController] with a [TextField]
/// to turn it into a rich text input field
void main() {
  runApp(const RichFieldExample());
}

class RichFieldExample extends StatelessWidget {
  const RichFieldExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: ThemeMode.dark,
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
  late final FocusNode _fieldFocusNode;
  late final RichFieldController _controller;
  // This is for demonstration only. You can define your own [TextSelectionControl]
  // and inject a [RichFieldController] in it to access the styling properties
  // late final RichFieldSelectionControls _selectionControls;

  @override
  void initState() {
    super.initState();
    _fieldFocusNode = FocusNode();
    _controller = RichFieldController(focusNode: _fieldFocusNode);
    // _selectionControls = RichFieldSelectionControls(context, _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.teal[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            RichfieldToolBarExample(_controller),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                padding: const EdgeInsets.all(14),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   border: Border.all(color: Colors.teal[200]!),
                //   borderRadius: BorderRadius.circular(4),
                // ),
                child: TextField(
                  controller: _controller,
                  focusNode: _fieldFocusNode,
                  maxLines: null,

                  // Use the style property to set a default style
                  // style: const TextStyle(
                  //   fontSize: 18,
                  //   height: 1.75,
                  //   color: Colors.black87,
                  // ),
                  // selectionControls: _selectionControls,
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
