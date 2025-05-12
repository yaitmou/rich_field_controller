import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rich_field_controller/rich_field_controller.dart';

class RichfieldToolBarExample extends StatefulWidget {
  final RichTextEditingController controller;
  const RichfieldToolBarExample(
    this.controller, {
    super.key,
  });

  @override
  State<RichfieldToolBarExample> createState() => _RichfieldToolBarExampleState();
}

class _RichfieldToolBarExampleState extends State<RichfieldToolBarExample> {
  RichTextEditingController get controller => widget.controller;

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
                      controller.toggleBold();
                    },
                    child: Icon(
                      CupertinoIcons.bold,
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
                      controller.toggleItalic();
                    },
                    child: Icon(
                      CupertinoIcons.italic,
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
                      controller.toggleUnderline();
                    },
                    child: Icon(
                      CupertinoIcons.underline,
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
                      controller.toggleStrikethrough();
                    },
                    child: Icon(
                      CupertinoIcons.strikethrough,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),

              //
              // toggle bullet list through Button
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      controller.toggleListItem();
                    },
                    child: Icon(
                      CupertinoIcons.list_bullet,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),

              //
              // toggle Numbered list through Button
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      controller.toggleNumberedList();
                    },
                    child: Icon(
                      CupertinoIcons.list_number,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
              //
              // Toggle Header
              //
              MenuAnchor(
                builder: (context, menuController, child) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: GestureDetector(
                        onTap: () {
                          if (menuController.isOpen) {
                            menuController.close();
                          } else {
                            menuController.open();
                          }
                          // controller.toggleHeader(1);
                        },
                        child: Icon(
                          CupertinoIcons.textformat_size,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  );
                },
                menuChildren: List.generate(
                  6,
                  (int i) => MenuItemButton(
                    onPressed: () {
                      controller.toggleHeader(i + 1);
                    },
                    child: Text('Level ${i + 1}'),
                  ),
                ),
              ),

              //
              // Export as HTML
              //
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      final c = controller.toMarkdown();
                      print('\n$c');
                    },
                    child: Icon(
                      CupertinoIcons.share,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),

              // //
              // // Heading levels text
              // //
              // DropdownMenu<int>(
              //   onSelected: (value) {
              //     if (value != null) {
              //       controller.toggleHeader(value);
              //     }
              //   },
              //   initialSelection: null,
              //   hintText: 'Heading',
              //   dropdownMenuEntries: const [
              //     DropdownMenuEntry(value: 1, label: 'H1'),
              //     DropdownMenuEntry(value: 2, label: 'H2'),
              //     DropdownMenuEntry(value: 3, label: 'H3'),
              //     DropdownMenuEntry(value: 4, label: 'H4'),
              //     DropdownMenuEntry(value: 5, label: 'H5'),
              //     DropdownMenuEntry(value: 6, label: 'H6'),
              //   ],
              // ),

              //
              // Highlight text
              //
              // MouseRegion(
              //   cursor: SystemMouseCursors.click,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              //     child: GestureDetector(
              //       onTap: () {
              //         controller.mainStyle = TextStyle(
              //           fontSize: 24,
              //           fontWeight: FontWeight.bold,
              //           color: Theme.of(context).hintColor,
              //           inherit: true,
              //         );
              //       },
              //       child: const Text(
              //         'H1',
              //         style: TextStyle(
              //           // color: Colors.black54,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              const Spacer(),
              //
              // Strike through Button
              //
              // MouseRegion(
              //   cursor: SystemMouseCursors.click,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              //     child: GestureDetector(
              //       onTap: () {
              //         controller.toMarkdown();
              //       },
              //       child: Icon(
              //         Icons.save_alt_rounded,
              //         color: Theme.of(context).hintColor,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
