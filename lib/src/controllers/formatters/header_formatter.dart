import 'package:flutter/services.dart';

typedef HeaderStyleCallback = void Function(int start, int end, int level);

class HeaderFormatter extends TextInputFormatter {
  final HeaderStyleCallback onHeaderFound;

  HeaderFormatter({required this.onHeaderFound});

  static const int maxHeaderLevel = 6;

  // Regex to match potential headers (including incomplete ones)
  final RegExp _headerRegex = RegExp(r'^(#{1,6})( )(.*)?\n', multiLine: true);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    int cursorOffset = newValue.selection.baseOffset;
    if (newValue == oldValue) {
      return newValue;
    }

    // Find all matches
    Iterable<RegExpMatch> matches = _headerRegex.allMatches(text);

    // Process matches
    for (RegExpMatch match in matches.toList()) {
      final headerSymbols = match.group(1)!;
      final headerLevel = headerSymbols.length.clamp(1, maxHeaderLevel);
      // final content = match.group(3) ?? '';

      final startIndex = match.start;
      final endIndex = match.end - headerLevel;

      onHeaderFound(startIndex, endIndex + 1, headerLevel);
    }

    final updatedValue = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursorOffset),
      composing: newValue.composing,
    );

    return updatedValue;
  }
}
