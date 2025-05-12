import 'package:rich_field_controller/src/domain/entities/rich_text_entity.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

class HtmlConverter {
  static String convertToHtml(RichTextEntity richTextEntity) {
    final StringBuffer buffer = StringBuffer();
    final List<RichTextSpan> spans = richTextEntity.spans;
    final String content = richTextEntity.content;

    // Add pre tag to preserve formatting
    buffer.write('<div style="white-space: pre-wrap; word-wrap: break-word;">');

    for (final span in spans) {
      final String text = _processText(content.substring(span.start, span.end));
      buffer.write(_applyStyle(text, span.style));
    }

    buffer.write('</div>');
    return buffer.toString();
  }

  /// Process text to preserve whitespace and line breaks
  static String _processText(String text) {
    // Replace newlines with explicit break tags
    // This ensures line breaks are preserved even within other HTML elements
    return text.replaceAll('\n', '<br>\n');
  }

  static String _applyStyle(String text, RichTextStyle style) {
    String result = text;

    // Apply styles while preserving whitespace
    if (style.isBold) {
      result = '<strong>$result</strong>';
    }
    if (style.isItalic) {
      result = '<em>$result</em>';
    }
    if (style.isStrikethrough) {
      result = '<del>$result</del>';
    }
    if (style.isUnderline) {
      result = '<u>$result</u>';
    }
    if (style.isCode) {
      result = '<code style="white-space: pre-wrap;">$result</code>';
    }
    if (style.isLink) {
      result = '<a href="${style.linkUrl ?? ''}" title="${style.linkTitle ?? ''}">$result</a>';
    }
    if (style.headerLevel != null) {
      // Headers should preserve their own spacing
      result =
          '<h${style.headerLevel} style="white-space: pre-wrap;">$result</h${style.headerLevel}>';
    }
    if (style.isBlockquote) {
      result = '<blockquote style="white-space: pre-wrap;">$result</blockquote>';
    }
    if (style.isImage) {
      result =
          '<img src="${style.imageUrl ?? ''}" alt="${style.imageAlt ?? ''}" title="${style.imageTitle ?? ''}">';
    }
    if (style.isList) {
      final String listType = style.isOrderedList ? 'ol' : 'ul';
      result = '<$listType style="white-space: pre-wrap;"><li>$result</li></$listType>';
    }
    if (style.isCheckbox) {
      final String checked = style.checkboxStatus == true ? ' checked' : '';
      result = '<div style="white-space: pre-wrap;"><input type="checkbox"$checked> $result</div>';
    }
    if (style.isHorizontalRule) {
      result = '<hr>';
    }
    if (style.isSuperscript) {
      result = '<sup>$result</sup>';
    }
    if (style.tableColumnAlignment != null) {
      final String align = style.tableColumnAlignment!;
      result = '<td align="$align" style="white-space: pre-wrap;">$result</td>';
    }
    if (style.isTableHeader) {
      result = '<th style="white-space: pre-wrap;">$result</th>';
    }

    return result;
  }
}
