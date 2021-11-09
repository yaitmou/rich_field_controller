import 'package:flutter/material.dart';
import 'package:rich_field_controller/src/rich_paragraph.dart';

/// The controller for each [TextField]
///
/// Takes a [FocusNode] to keep focus on the text being edited.
/// That is particularly useful when using a toolbar to style the selected text
class RichFieldController extends TextEditingController {
  FocusNode node;
  RichFieldController(this.node);

  late final _paragraph = RichParagraph(node);

  // RichParagraph get paragraph => _paragraph;
  void updateStyle(TextStyle style) {
    selection = _paragraph.selection;
    _paragraph.updateSelectedTextStyle(style);
  }

  @override
  set value(TextEditingValue newValue) {
    _paragraph.updateText(text);
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    if (selection != _paragraph.selection) {
      _paragraph.updateSelection(selection);
    }
    return TextSpan(style: style, children: _paragraph.buildTextSpans());
  }
}
