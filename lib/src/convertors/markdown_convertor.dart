import 'package:rich_field_controller/src/domain/entities/rich_text_entity.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

class MarkdownConverter {
  static String convertToMarkdown(RichTextEntity richTextEntity) {
    final StringBuffer buffer = StringBuffer();
    final List<RichTextSpan> spans = richTextEntity.spans;
    final String content = richTextEntity.content;

    for (final span in spans) {
      final String text = content.substring(span.start, span.end);
      buffer.write(_applyStyle(text, span.style));
    }

    return buffer.toString();
  }

  static String _applyStyle(String text, RichTextStyle style) {
    String result = text;

    if (style.isBold) {
      result = '**$result**';
    }
    if (style.isItalic) {
      result = '_${result}_';
    }
    if (style.isStrikethrough) {
      result = '~~$result~~';
    }
    if (style.isCode) {
      result = '`$result`';
    }
    if (style.isLink) {
      result = '[$result](${style.linkUrl ?? ''} "${style.linkTitle ?? ''}")';
    }
    if (style.headerLevel != null) {
      result = '${'#' * style.headerLevel!} $result';
    }
    if (style.isBlockquote) {
      result = result.split('\n').map((line) => '> $line').join('\n');
    }
    if (style.isImage) {
      result = '![${style.imageAlt ?? ''}](${style.imageUrl ?? ''} "${style.imageTitle ?? ''}")';
    }
    if (style.isList) {
      final String listMarker = style.isOrderedList ? '1. ' : '- ';
      result = result.split('\n').map((line) => '$listMarker$line').join('\n');
    }
    if (style.isCheckbox) {
      final String checkboxMarker = style.checkboxStatus == true ? '[x]' : '[ ]';
      result = '$checkboxMarker $result';
    }
    if (style.isHorizontalRule) {
      result = '---';
    }
    if (style.isSuperscript) {
      // Markdown doesn't have native superscript, we'll use HTML
      result = '<sup>$result</sup>';
    }
    if (style.tableColumnAlignment != null || style.isTableHeader) {
      // Table handling in Markdown is more complex and depends on the full table structure
      // For simplicity, we'll just return the text content here
      // In a more comprehensive implementation, you'd need to handle the entire table at once
    }

    return result;
  }
}
