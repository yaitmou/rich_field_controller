import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

enum HtmlTags {
  bold(
    openingTag: '<strong>',
    closingTag: '</strong>',
    openingTagLength: 8,
    closingTagLength: 9,
    style: RichTextStyle(isBold: true),
  ),
  italic(
    openingTag: '<em>',
    closingTag: '</em>',
    openingTagLength: 4,
    closingTagLength: 5,
    style: RichTextStyle(isItalic: true),
  ),
  strikethrough(
    openingTag: '<del>',
    closingTag: '</del>',
    openingTagLength: 5,
    closingTagLength: 6,
    style: RichTextStyle(isStrikethrough: true),
  ),
  inlineCode(
    openingTag: '<code>',
    closingTag: '</code>',
    openingTagLength: 6,
    closingTagLength: 7,
    style: RichTextStyle(isCode: true),
  );

  final String openingTag;
  final String closingTag;
  final RichTextStyle style;
  final int openingTagLength;
  final int closingTagLength;
  const HtmlTags({
    required this.openingTag,
    required this.closingTag,
    required this.openingTagLength,
    required this.closingTagLength,
    required this.style,
  });
}
