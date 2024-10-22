import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
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
                      MdiIcons.formatBold,
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
                      MdiIcons.formatItalic,
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
                      MdiIcons.formatUnderline,
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
                      MdiIcons.formatStrikethrough,
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
                      controller.toggleListItem();
                    },
                    child: Icon(
                      MdiIcons.formatListBulleted,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),

              //
              // Heading levels text
              //
              DropdownMenu<int>(
                onSelected: (value) {
                  if (value != null) {
                    controller.toggleHeader(value);
                  }
                },
                initialSelection: null,
                hintText: 'Heading',
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 1, label: 'H1'),
                  DropdownMenuEntry(value: 2, label: 'H2'),
                  DropdownMenuEntry(value: 3, label: 'H3'),
                  DropdownMenuEntry(value: 4, label: 'H4'),
                  DropdownMenuEntry(value: 5, label: 'H5'),
                  DropdownMenuEntry(value: 6, label: 'H6'),
                ],
              ),

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
