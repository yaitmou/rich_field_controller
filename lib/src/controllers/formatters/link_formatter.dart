// src/controllers/formatters/link_formatter.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef LinkStyleCallback = void Function(String text, String url, int start, int end);

class LinkFormatter extends TextInputFormatter {
  final LinkStyleCallback onLinkFound;

  LinkFormatter({required this.onLinkFound});

  // Regular expression for Markdown links [text](url)
  // This pattern matches:
  // - Opening square bracket
  // - Any characters except closing bracket (captured as group 1)
  // - Closing square bracket
  // - Opening parenthesis
  // - Any characters except closing parenthesis (captured as group 2)
  // - Closing parenthesis
  final RegExp _linkPattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

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

    // Check if we have a potential link pattern
    final matches = _linkPattern.allMatches(text);

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

    for (final match in sortedMatches) {
      final linkText = match[1]!;
      final url = match[2]!;
      final fullMatchStart = match.start;
      final fullMatchEnd = match.end;

      // Check if this is a newly added link pattern
      // by comparing with the old text
      bool isNewLink = false;
      if (fullMatchEnd <= oldValue.text.length) {
        final oldSubstring = oldValue.text.substring(fullMatchStart, fullMatchEnd);
        isNewLink = oldSubstring != match[0];
      } else {
        isNewLink = true;
      }

      // Process if either:
      // 1. This is a new link pattern, or
      // 2. The cursor is right after completing the pattern
      if (isNewLink || cursorPosition == fullMatchEnd) {
        // Remove the markdown syntax but keep the link text
        text = text.replaceRange(fullMatchStart, fullMatchEnd, linkText);

        // Adjust cursor position
        final adjustment = (fullMatchEnd - fullMatchStart - linkText.length);
        if (cursorPosition > fullMatchStart) {
          cursorAdjustment += adjustment;
        }

        onLinkFound(
          linkText,
          url,
          fullMatchStart,
          fullMatchStart + linkText.length,
        );
      }
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
