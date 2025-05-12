import 'package:flutter/material.dart';
import 'package:rich_field_controller/injection_container.dart';
import 'package:rich_field_controller/rich_field_controller.dart';
import 'package:rich_field_example/toolbar.dart';

/// This example illustrates how to use a [RichTextController] with a [TextField]
/// to turn it into a rich text input field
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initRichTextEditingController();

  runApp(const RichFieldExample());
}

class RichFieldExample extends StatelessWidget {
  const RichFieldExample({super.key});

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
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final FocusNode _fieldFocusNode;
  late final RichTextEditingController _controller;
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fieldFocusNode = FocusNode();
    _controller = RichTextEditingController(
      context: context,
      textFieldKey: _textFieldKey,
    );
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
                constraints: const BoxConstraints(maxWidth: 900, maxHeight: 900),
                padding: const EdgeInsets.all(14),
                child: TextField(
                  key: _textFieldKey,
                  controller: _controller,
                  focusNode: _fieldFocusNode,
                  maxLines: null,
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
                  onChanged: (value) {
                    // _controller.caretPosition;
                  },
                  inputFormatters: _controller.formatters,
                  style: const TextStyle(height: 1.7),
                  strutStyle: StrutStyle.disabled,
                  // cursorHeight: 56,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
