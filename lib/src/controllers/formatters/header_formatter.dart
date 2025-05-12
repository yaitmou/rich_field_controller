import 'package:flutter/services.dart';
import 'package:rich_field_controller/src/commands/header_command.dart';

typedef HeaderCommandCallback = void Function(HeaderCommand command);

class HeaderFormatter extends TextInputFormatter {
  final HeaderCommandCallback onHeaderCommand;
  static const int maxHeaderLevel = 6;

  HeaderFormatter({required this.onHeaderCommand});

  // Regex to match potential headers (including incomplete ones)
  final RegExp _headerRegex = RegExp(r'^(#{1,6})( )(.+)\n$', multiLine: true);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    int cursorPosition = newValue.selection.baseOffset;

    // If text was deleted, don't process
    if (newValue == oldValue || text.length < oldValue.text.length) {
      return newValue;
    }

    // Find all matches
    final matches = _headerRegex.allMatches(text);

    // No matches found
    if (matches.isEmpty) {
      return newValue;
    }
    // Process matches in reverse order to handle multiple links
    // and maintain correct indices after text modifications
    final List<RegExpMatch> sortedMatches = matches.toList()
      ..sort((a, b) => b.start.compareTo(a.start));

    // Track cursor position adjustments
    int cursorAdjustment = 0;

    // Process matches
    for (RegExpMatch match in sortedMatches) {
      final headerSymbols = match.group(1)!;
      final headerLevel = headerSymbols.length.clamp(1, maxHeaderLevel);
      final content = match.group(3) ?? '';
      final fullMatchStart = match.start;
      final fullMatchEnd = match.start + content.length + headerLevel + 1;

      // Check if this is a newly added link pattern
      // by comparing with the old text
      bool isNewHeader = false;
      if (fullMatchEnd <= oldValue.text.length) {
        final oldSubstring = oldValue.text.substring(fullMatchStart, fullMatchEnd);
        isNewHeader = oldSubstring != match[0];
      } else {
        isNewHeader = true;
      }

      // Process if either:
      if (content.isNotEmpty || isNewHeader || cursorPosition == fullMatchEnd) {
        // Remove the markdown syntax but keep the header text
        text = text.replaceRange(fullMatchStart, fullMatchEnd, content);
      }
      // Adjust cursor position
      final adjustment = (fullMatchEnd - fullMatchStart - content.length);
      if (cursorPosition > fullMatchStart) {
        cursorAdjustment += adjustment;
      }

      onHeaderCommand(
        HeaderCommand(
          start: fullMatchStart,
          end: fullMatchStart + content.length,
          level: headerLevel,
        ),
      );
    }

    // Adjust cursor position based on all modifications
    cursorPosition -= cursorAdjustment;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursorPosition),
      composing: newValue.composing,
    );
  }
}
