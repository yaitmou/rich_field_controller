import 'package:flutter/services.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

typedef InlineStyleCallback = void Function(RichTextStyle style, int start, int end);

class InlineMarkdownFormatter extends TextInputFormatter {
  final InlineStyleCallback onStyleFound;

  InlineMarkdownFormatter({required this.onStyleFound});

  // Regular expressions for different markdown patterns
  static final Map<String, ({String pattern, RichTextStyle style, int tagLength})>
      _markdownPatterns = {
    'bold': (
      pattern: r'\*\*(.*?)\*\*',
      style: const RichTextStyle(isBold: true),
      tagLength: 2, // Length of '**'
    ),
    'italic': (
      pattern: r'_(.*?)_',
      style: const RichTextStyle(isItalic: true),
      tagLength: 1, // Length of '_'
    ),
    'strikethrough': (
      pattern: r'~~(.*?)~~',
      style: const RichTextStyle(isStrikethrough: true),
      tagLength: 2, // Length of '~~'
    ),
    'code': (
      pattern: r'`(.*?)`',
      style: const RichTextStyle(isCode: true),
      tagLength: 1, // Length of '`'
    ),
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    int cursorPosition = newValue.selection.baseOffset;

    // If text was deleted, don't process
    if (text.length < oldValue.text.length) {
      return newValue;
    }

    // Process each markdown pattern
    for (final pattern in _markdownPatterns.entries) {
      final regex = RegExp(pattern.value.pattern);
      final matches = regex.allMatches(text);

      // No matches found for this pattern
      if (matches.isEmpty) continue;

      // Process matches in reverse order to handle multiple patterns
      final List<RegExpMatch> sortedMatches = matches.toList()
        ..sort((a, b) => b.start.compareTo(a.start));

      // Track cursor position adjustments
      int cursorAdjustment = 0;

      for (final match in sortedMatches) {
        final innerText = match.group(1)!;
        final fullMatchStart = match.start;
        final fullMatchEnd = match.end;

        // Check if this is a newly added pattern
        bool isNewPattern = false;
        if (fullMatchEnd <= oldValue.text.length) {
          final oldSubstring = oldValue.text.substring(fullMatchStart, fullMatchEnd);
          isNewPattern = oldSubstring != match[0];
        } else {
          isNewPattern = true;
        }

        // Process if either:
        // 1. This is a new pattern, or
        // 2. The cursor is right after completing the pattern
        if (isNewPattern || cursorPosition == fullMatchEnd) {
          // Calculate the positions in the text without markdown syntax
          final int contentStart = fullMatchStart;
          final int contentEnd = contentStart + innerText.length;

          // Remove the markdown syntax but keep the text
          text = text.replaceRange(fullMatchStart, fullMatchEnd, innerText);

          // Adjust cursor position
          final adjustment = (fullMatchEnd - fullMatchStart - innerText.length);
          if (cursorPosition > fullMatchStart) {
            cursorAdjustment += adjustment;
          }

          // Notify about the style to be applied
          onStyleFound(pattern.value.style, contentStart, contentEnd);
        }
      }

      // Adjust cursor position based on all modifications
      cursorPosition -= cursorAdjustment;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursorPosition),
      composing: newValue.composing,
    );
  }
}
