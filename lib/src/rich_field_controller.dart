import 'package:flutter/material.dart';
import 'package:rich_field_controller/src/rich_paragraph.dart';

/// The controller to be used as a [TextEditingController] for a [TextField]
///
/// Takes a [FocusNode] to keep focus on the text being edited.
/// That is particularly useful when using a toolbar to style the selected text.
/// If [FocusNode] is omitted, whenever the text is styled through a toolbar action,
/// the [TextField] will loos focus.
class RichFieldController extends TextEditingController {
  /// The [TextField]'s [FocusNode]
  FocusNode? focusNode;
  RichFieldController({this.focusNode});

  late final _paragraph = RichParagraph(node: focusNode);

  /// This is the core function of the [rich_field_controller]. I takes a required [style]
  /// and applies it to the selected text. If there is no active selection, but
  /// the focus is still on the [TextFiled], then the style is applied to the word
  /// containing the cursor.
  void updateStyle(TextStyle style) {
    selection = _paragraph.selection ?? selection;
    _paragraph.updateSelectedTextStyle(style);
  }

  @override
  set value(TextEditingValue newValue) {
    _paragraph.updateText(text);
    super.value = newValue;
  }

  /// Traverses the current editing value, splits it based on style, and builds [TextSpans]
  /// If there are no applied spans, it builds a single span containing the editing value's text
  /// and the default [style]
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (selection != _paragraph.selection) {
      _paragraph.updateSelection(selection);
    }
    return TextSpan(style: style, children: _paragraph.buildTextSpans());
  }
}
