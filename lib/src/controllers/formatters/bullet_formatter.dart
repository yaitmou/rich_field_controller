import 'package:flutter/services.dart';

class BulletPointFormatter extends TextInputFormatter {
  static const String bullet = '\u2022';
  static const String bulletWithPadding = '  $bullet ';

  // Regular expression to match bullet points at the start of a line
  final RegExp _bulletRegex = RegExp(r'(^|\n)  • ');

  // Regular expression to match hyphen and space at the start of a line
  final RegExp _hyphenRegex = RegExp(r'(^|\n)- ');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    int cursorPosition = newValue.selection.baseOffset;

    // Convert '- ' to bullet point
    if (text.length == oldValue.text.length + 1) {
      final match = _hyphenRegex.firstMatch(text.substring(0, cursorPosition));
      if (match != null && match.end == cursorPosition) {
        final startIndex = match.start;
        text = text.replaceRange(startIndex, cursorPosition, '${match.group(1)}$bulletWithPadding');
        cursorPosition = startIndex + bulletWithPadding.length + (match.group(1)?.length ?? 0);
      }
    }

    // Handle new line after bullet point
    if (text.length == oldValue.text.length + 1 && text.contains(oldValue.text)) {
      try {
        final lastBulletMatch = _bulletRegex.allMatches(text).lastWhere(
              (match) => match.end <= cursorPosition,
            );

        final lineStart = lastBulletMatch.start;
        final lineEnd = text.indexOf('\n', lastBulletMatch.end);
        final currentLine =
            lineEnd == -1 ? text.substring(lineStart) : text.substring(lineStart, lineEnd);

        if (currentLine.trim() == bullet &&
            text.substring(cursorPosition - 1, cursorPosition) == '\n') {
          // Remove empty bullet point
          text = text.replaceRange(lineStart, cursorPosition, '\n');
          cursorPosition = lineStart + 1;
        } else if (text.substring(cursorPosition - 1, cursorPosition) == '\n' &&
            cursorPosition == lineEnd + 1) {
          // Add new bullet point only if Enter was pressed at the end of a bullet point line
          text = text.replaceRange(cursorPosition, cursorPosition, bulletWithPadding);
          cursorPosition += bulletWithPadding.length;
        }
      } catch (_) {}
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
