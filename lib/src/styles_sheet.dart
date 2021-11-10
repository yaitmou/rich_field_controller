import 'package:flutter/material.dart';

class MarkDownStyle {
  final String opening;
  final String closing;
  // Defines whether to set a closing tag or not
  final bool isSingleTag;
  MarkDownStyle(
      {required this.opening, String? closing, this.isSingleTag = false})
      : closing = isSingleTag ? '' : closing ?? opening;
}

Map<TextStyle, MarkDownStyle> stylesMap = {
  const TextStyle(fontWeight: FontWeight.bold): MarkDownStyle(opening: '**'),
  const TextStyle(fontStyle: FontStyle.italic): MarkDownStyle(opening: '*'),
  const TextStyle(decoration: TextDecoration.underline): MarkDownStyle(
    opening: '<u>',
    closing: '</u>',
  ),
  const TextStyle(decoration: TextDecoration.lineThrough): MarkDownStyle(
    opening: '~~',
  ),
};
