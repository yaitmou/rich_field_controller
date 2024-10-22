// import 'package:flutter/services.dart';

// typedef BlockQuoteCallback = void Function(String quoteText);

// class BlockQuoteFormatter extends TextInputFormatter {
//   static const String blockQuotePrefix = '> ';
//   static const String blockQuotePrefixWithPadding = '    ';

//   BlockQuoteFormatter();

//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     String oldText = oldValue.text;
//     String newText = newValue.text;
//     int cursorPosition = newValue.selection.baseOffset;

//     // Check if a newline was just added
//     if (newText.length == oldText.length + 1 &&
//         newText.substring(cursorPosition - 1, cursorPosition) == '\n') {
//       // Find the start of the current line
//       int lineStart = newText.lastIndexOf('\n', cursorPosition - 2) + 1;
//       String currentLine = newText.substring(lineStart, cursorPosition - 1);

//       if (currentLine.startsWith(blockQuotePrefix)) {
//         // We're in a block quote
//         if (currentLine.trim() == blockQuotePrefix.trim()) {
//           // Empty block quote line, exit the block quote
//           newText = newText.replaceRange(lineStart, cursorPosition, '\n\n');
//           cursorPosition = lineStart + 1;
//         } else {
//           // Capture the quote text
//           String quoteText = currentLine.substring(blockQuotePrefix.length);
//           print(quoteText);

//           // Continue the block quote, replace "> " with four spaces
//           newText = newText.replaceRange(
//               lineStart, lineStart + blockQuotePrefix.length, blockQuotePrefixWithPadding);
//           newText =
//               newText.replaceRange(cursorPosition, cursorPosition, blockQuotePrefixWithPadding);
//           cursorPosition += blockQuotePrefixWithPadding.length;
//         }
//       } else if (currentLine.trim().startsWith('>')) {
//         // Convert '>' to proper block quote format with four spaces
//         newText = newText.replaceRange(lineStart, cursorPosition,
//             '$blockQuotePrefixWithPadding${currentLine.trim().substring(1)}\n$blockQuotePrefixWithPadding');
//         cursorPosition = lineStart +
//             blockQuotePrefixWithPadding.length +
//             currentLine.trim().length -
//             1 +
//             1 +
//             blockQuotePrefixWithPadding.length;

//         // Capture the quote text
//         String quoteText = currentLine.trim().substring(1);
//         onBlockQuoteEntered?.call(quoteText);
//       }
//     } else if (newText.length > oldText.length) {
//       // Check if '> ' was just typed at the start of a line
//       int lineStart = newText.lastIndexOf('\n', cursorPosition - 1) + 1;
//       if (cursorPosition - lineStart == blockQuotePrefix.length &&
//           newText.substring(lineStart, cursorPosition) == blockQuotePrefix) {
//         // Replace '> ' with four spaces
//         newText = newText.replaceRange(lineStart, cursorPosition, blockQuotePrefixWithPadding);
//         cursorPosition = lineStart + blockQuotePrefixWithPadding.length;
//       }
//     }

//     return TextEditingValue(
//       text: newText,
//       selection: TextSelection.collapsed(offset: cursorPosition),
//     );
//   }
// }
