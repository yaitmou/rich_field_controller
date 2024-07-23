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
                      controller.updateStyle(
                        const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                    child: Icon(
                      Icons.format_bold_rounded,
                      color: Theme.of(context).hintColor,
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
                    child: Icon(
                      Icons.format_italic_rounded,
                      color: Theme.of(context).hintColor,
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
                    child: Icon(
                      Icons.format_underline_rounded,
                      color: Theme.of(context).hintColor,
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
                      controller
                          .updateStyle(const TextStyle(decoration: TextDecoration.lineThrough));
                    },
                    child: Icon(
                      Icons.format_strikethrough_rounded,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),

              //
              // Highlight text
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      controller.updateStyle(
                        TextStyle(
                          background: Paint()..color = Colors.yellow,
                        ),
                      );
                    },
                    child: Icon(
                      Icons.format_color_fill_rounded,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
              //
              // Highlight text
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      controller.mainStyle = TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                        inherit: true,
                      );
                    },
                    child: const Text(
                      'H1',
                      style: TextStyle(
                        // color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              //
              // Strike through Button
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      controller.toMarkdown();
                    },
                    child: Icon(
                      Icons.save_alt_rounded,
                      color: Theme.of(context).hintColor,
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
