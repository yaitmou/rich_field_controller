import 'package:flutter/material.dart';
import 'package:rich_field_controller/rich_field_controller.dart';

class RichfieldToolBarExample extends StatefulWidget {
  final RichFieldController controller;
  const RichfieldToolBarExample(
    this.controller, {
    Key? key,
  }) : super(key: key);

  @override
  _RichfieldToolBarExampleState createState() => _RichfieldToolBarExampleState();
}

class _RichfieldToolBarExampleState extends State<RichfieldToolBarExample> {
  RichFieldController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 14),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: IntrinsicHeight(
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              //
              // Bold Button
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8).copyWith(left: 0),
                  child: GestureDetector(
                    onTap: () {
                      controller.updateStyle(const TextStyle(fontWeight: FontWeight.bold));
                    },
                    child: const Icon(
                      Icons.format_bold_rounded,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              //
              // Italic Button
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      controller.updateStyle(const TextStyle(fontStyle: FontStyle.italic));
                    },
                    child: const Icon(
                      Icons.format_italic_rounded,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              //
              // UnderLine Button
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      controller.updateStyle(const TextStyle(decoration: TextDecoration.underline));
                    },
                    child: const Icon(
                      Icons.format_underline_rounded,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              //
              // Strike through Button
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      controller.updateStyle(const TextStyle(decoration: TextDecoration.lineThrough));
                    },
                    child: const Icon(
                      Icons.format_strikethrough_rounded,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
