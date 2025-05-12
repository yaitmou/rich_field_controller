import 'package:flutter/services.dart';

class NumberListFormatter extends TextInputFormatter {
  // Updated regex to be more strict about initial spacing
  final RegExp _numberListRegex = RegExp(r'(^|\n)(\s*)\d+\.\s');
  final RegExp _startingNumberRegex = RegExp(r'\d+');
  static const String listItemIndent = '  '; // Two spaces for indentation

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    int cursorPosition = newValue.selection.baseOffset;

    if (text.isEmpty || cursorPosition <= 0) {
      return newValue;
    }

    // Handle deletion case
    if (text.length < oldValue.text.length) {
      try {
        // Find the current line start
        final int currentLineStart = text.lastIndexOf('\n', cursorPosition);

        // Check if next line is part of a list (indicates we're in a list)
        final int nextLineStart = text.indexOf('\n', cursorPosition);
        final String nextLine = nextLineStart != -1
            ? text.substring(cursorPosition, nextLineStart).trim()
            : text.substring(cursorPosition).trim();

        bool isInList = _numberListRegex.hasMatch(nextLine);

        // If we're not sure yet, check previous line
        if (!isInList) {
          // Find the previous line to check if we're in a list
          final int prevLineStart = text.lastIndexOf('\n', currentLineStart - 1);
          final String prevLine = text.substring(
            prevLineStart >= 0 ? prevLineStart + 1 : 0,
            currentLineStart >= 0 ? currentLineStart : text.length,
          );

          isInList = _numberListRegex.hasMatch(prevLine);
        }

        if (isInList) {
          int startNumber = 1; // Default to 1 if we're at the start of the list

          // Try to get number from previous line if it exists
          if (currentLineStart > 0) {
            final int prevLineStart = text.lastIndexOf('\n', currentLineStart - 1);
            if (prevLineStart >= 0) {
              final String prevLine = text
                  .substring(
                    prevLineStart + 1,
                    currentLineStart,
                  )
                  .trim();

              final prevNumberStr = _startingNumberRegex.firstMatch(prevLine)?.group(0);
              if (prevNumberStr != null && _numberListRegex.hasMatch(prevLine)) {
                startNumber = int.parse(prevNumberStr) + 1;
              }
            }
          }

          // Ensure consistent indentation when renumbering
          text = renumberSubsequentItems(
            text,
            currentLineStart >= 0 ? currentLineStart + 1 : 0,
            startNumber,
          );

          return TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: cursorPosition),
          );
        }
      } catch (e) {
        return newValue;
      }
      return newValue;
    }

    // Check if a new line was just added
    if (text.length == oldValue.text.length + 1 &&
        text.substring(cursorPosition - 1, cursorPosition) == '\n') {
      try {
        int startAt = cursorPosition - 2;

        final int currentLineStart = text.lastIndexOf('\n', startAt);
        if (currentLineStart < 0) {
          return newValue;
        }

        // Get the current line's content before the newline
        final String currentLine = text.substring(
          currentLineStart + 1,
          cursorPosition - 1,
        );

        // Check if the current line is part of a numbered list
        final numberMatch = _numberListRegex.firstMatch(currentLine);
        if (numberMatch != null) {
          try {
            final numberStr = _startingNumberRegex.firstMatch(currentLine)?.group(0);
            if (numberStr != null) {
              final currentNumber = int.parse(numberStr);

              // If the line only contains the number and period, exit the list
              if (currentLine.trim() == '$currentNumber.') {
                text = text.replaceRange(currentLineStart + 1, cursorPosition, '\n');
                cursorPosition = currentLineStart + 2;
              } else {
                // Create next list item with consistent indentation
                final nextNumber = currentNumber + 1;
                final listMarker = '$listItemIndent$nextNumber. ';

                // Insert the new list item
                text = text.replaceRange(cursorPosition, cursorPosition, listMarker);
                cursorPosition += listMarker.length;

                // Now we need to renumber all subsequent list items
                text = renumberSubsequentItems(text, cursorPosition, nextNumber + 1);
              }
            }
          } catch (e) {
            return newValue;
          }
        } else {
          try {
            int prevLineStart = text.lastIndexOf('\n', currentLineStart - 1);
            if (prevLineStart < 0) prevLineStart = 0;

            final String prevLine = text.substring(prevLineStart, currentLineStart).trim();
            final prevNumberMatch = _numberListRegex.firstMatch(prevLine);

            if (prevNumberMatch != null) {
              if (currentLine.trim().isEmpty) {
                return newValue;
              }

              final prevNumberStr = _startingNumberRegex.firstMatch(prevLine)?.group(0);
              if (prevNumberStr != null) {
                final prevNumber = int.parse(prevNumberStr);
                final nextNumber = prevNumber + 1;
                final listMarker = '$listItemIndent$nextNumber. ';

                // Ensure consistent indentation for new items
                text = text.replaceRange(currentLineStart + 1, currentLineStart + 1, listMarker);
                cursorPosition += listMarker.length;

                // Renumber subsequent items with consistent indentation
                text = renumberSubsequentItems(text, cursorPosition, nextNumber + 1);
              }
            }
          } catch (e) {
            return newValue;
          }
        }
      } catch (_) {
        // Here we are caching all unwanted error
        // Need to properly handle that....
        // For instance if the doc is empty and we hit return to add a `\n` we get an out of
        // range exception: try it out and implement a more gracious error handling!
      }
    } else if (text.length > oldValue.text.length) {
      try {
        // Check if user just typed a number followed by a period
        final match = RegExp(r'(^|\n)(\s*)(\d+)(\.\s)$').firstMatch(
          text.substring(0, cursorPosition),
        );

        if (match != null && match.end == cursorPosition) {
          // If this is the start of a list, ensure proper indentation
          final beforeNumber = match.group(2) ?? '';
          if (beforeNumber.length != listItemIndent.length) {
            final startPos = match.start + (match.group(1)?.length ?? 0);
            final number = match.group(3);
            final newListItem = '$listItemIndent$number. ';
            text = text.replaceRange(startPos, match.end, newListItem);
            cursorPosition = startPos + newListItem.length;

            return TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: cursorPosition),
            );
          }
        }
      } catch (e) {
        return newValue;
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  String renumberSubsequentItems(String text, int startPosition, int startNumber) {
    String remainingText = text.substring(startPosition);
    final matches = _numberListRegex.allMatches(remainingText).toList();
    if (matches.isEmpty) return text;

    int listEndPosition = remainingText.length;
    for (int i = 0; i < matches.length - 1; i++) {
      final currentMatchEnd = matches[i].end;
      final nextMatchStart = matches[i + 1].start;
      final textBetween = remainingText.substring(currentMatchEnd, nextMatchStart).trim();

      if (textBetween.contains('\n')) {
        listEndPosition = currentMatchEnd;
        break;
      }
    }

    final listMatches = matches.takeWhile((match) => match.start <= listEndPosition).toList();
    String newText = text.substring(0, startPosition);
    int lastEnd = 0;
    int numberOffset = startNumber;

    for (final match in listMatches) {
      newText += remainingText.substring(lastEnd, match.start);
      final currentNumberMatch = _startingNumberRegex.firstMatch(
        remainingText.substring(match.start, match.end),
      );

      if (currentNumberMatch != null) {
        final oldNumberStr = currentNumberMatch.group(0)!;
        final newNumberStr = numberOffset.toString();

        // Ensure consistent indentation when replacing numbers
        final oldLine = remainingText.substring(match.start, match.end);
        final newLine =
            '$listItemIndent$newNumberStr. ${oldLine.trimLeft().substring(oldNumberStr.length + 2)}';

        newText += match.group(1) ?? ''; // Preserve any line breaks
        newText += newLine;

        numberOffset++;
      } else {
        newText += remainingText.substring(match.start, match.end);
      }

      lastEnd = match.end;
    }

    newText += remainingText.substring(lastEnd);
    return newText;
  }
}
