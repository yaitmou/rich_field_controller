import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

enum MarkdownTags {
  bold(
    openingTag: '**',
    closingTag: '**',
    openingTagLength: 2,
    closingTagLength: 2,
    style: RichTextStyle(isBold: true),
  ),
  italic(
    openingTag: '_',
    closingTag: '_',
    openingTagLength: 1,
    closingTagLength: 1,
    style: RichTextStyle(isItalic: true),
  ),
  strikethrough(
    openingTag: '~~',
    closingTag: '~~',
    openingTagLength: 2,
    closingTagLength: 2,
    style: RichTextStyle(isStrikethrough: true),
  ),

  inlineCode(
    openingTag: '`',
    closingTag: '`',
    openingTagLength: 1,
    closingTagLength: 1,
    style: RichTextStyle(isCode: true),
  );

  final String openingTag;
  final String closingTag;
  final RichTextStyle style;
  final int openingTagLength;
  final int closingTagLength;
  const MarkdownTags({
    required this.openingTag,
    required this.closingTag,
    required this.openingTagLength,
    required this.closingTagLength,
    required this.style,
  });
}
