import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rich_field_controller/rich_field_controller.dart';

/// Handles the formatting options that appear on the contextual menu.
/// That is when a left click is detected.
///
/// If there is a selection range, the selected text will be formatted.
/// Otherwise, if the the field has focus and the cursor is placed
/// at the beginning, in the middle, or at the end of a word, that word
/// will be formatted
class RichFieldSelectionControls extends MaterialTextSelectionControls {
  final RichFieldController controller;
  final BuildContext context;

  RichFieldSelectionControls(this.context, this.controller);

  void _updateTextStyle(TextSelectionDelegate delegate, TextStyle newStyle) {
    controller.updateStyle(newStyle);
    delegate.bringIntoView(delegate.textEditingValue.selection.extent);
    delegate.userUpdateTextEditingValue(
      TextEditingValue(
        text: delegate.textEditingValue.text,
        selection: TextSelection.collapsed(
          offset: delegate.textEditingValue.selection.end,
        ),
      ),
      SelectionChangedCause.toolBar,
    );
    delegate.hideToolbar();
  }

  void _handleBold(TextSelectionDelegate delegate) {
    _updateTextStyle(delegate, const TextStyle(fontWeight: FontWeight.bold));
  }

  void _handleItalic(TextSelectionDelegate delegate) {
    _updateTextStyle(delegate, const TextStyle(fontStyle: FontStyle.italic));
  }

  // todo cZombine multiple [TextDecoration]s by using [TextDecoration.combine]

  void _handleUnderLine(TextSelectionDelegate delegate) {
    _updateTextStyle(
      delegate,
      const TextStyle(decoration: TextDecoration.underline),
    );
  }

  void _handleStrickThrough(TextSelectionDelegate delegate) {
    _updateTextStyle(
      delegate,
      const TextStyle(decoration: TextDecoration.lineThrough),
    );
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return TextSelectionToolbar(
      anchorAbove: lastSecondaryTapDownPosition! + const Offset(0, -24),
      anchorBelow: lastSecondaryTapDownPosition + const Offset(0, 24),
      toolbarBuilder: (context, child) => Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(50),
        ),
        child: child,
      ),
      children: <Widget>[
        TextSelectionToolbarTextButton(
          child: const Icon(Icons.cut_rounded, size: 22, color: Colors.black87),
          padding: const EdgeInsets.all(8.0).copyWith(left: 18),
          onPressed: canCut(delegate) ? () => handleCut(delegate) : null,
        ),
        TextSelectionToolbarTextButton(
          child:
              const Icon(Icons.copy_rounded, size: 22, color: Colors.black87),
          padding: const EdgeInsets.all(8.0),
          onPressed: canCopy(delegate)
              ? () => handleCopy(delegate, clipboardStatus)
              : null,
        ),
        TextSelectionToolbarTextButton(
          child:
              const Icon(Icons.paste_rounded, size: 22, color: Colors.black87),
          padding: const EdgeInsets.all(8.0),
          onPressed: canPaste(delegate) ? () => handlePaste(delegate) : null,
        ),
        //
        // Bold
        //
        TextSelectionToolbarTextButton(
          child: const Icon(
            Icons.format_bold_rounded,
            size: 22,
            color: Colors.black87,
          ),
          padding: const EdgeInsets.all(8.0),
          onPressed: () => _handleBold(delegate),
        ),

        //
        // Italic
        //
        TextSelectionToolbarTextButton(
          child: const Icon(
            Icons.format_italic_rounded,
            size: 22,
            color: Colors.black87,
          ),
          padding: const EdgeInsets.all(8.0),
          onPressed: () => _handleItalic(delegate),
        ),

        //
        // Underline
        //
        TextSelectionToolbarTextButton(
          child: const Icon(
            Icons.format_underline_rounded,
            size: 22,
            color: Colors.black87,
          ),
          padding: const EdgeInsets.all(8.0),
          onPressed: () => _handleUnderLine(delegate),
        ),

        //
        // strick through
        //
        TextSelectionToolbarTextButton(
          child: const Icon(
            Icons.format_strikethrough_rounded,
            size: 22,
            color: Colors.black87,
          ),
          padding: const EdgeInsets.all(8.0).copyWith(right: 18),
          onPressed: () => _handleStrickThrough(delegate),
        ),
      ],
    );
  }
}
