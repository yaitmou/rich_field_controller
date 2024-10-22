import 'package:rich_field_controller/src/domain/entities/rich_text_entity.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

class HtmlConverter {
  static String convertToHtml(RichTextEntity richTextEntity) {
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
      result = '<code>$result</code>';
    }
    if (style.isLink) {
      result = '<a href="${style.linkUrl ?? ''}" title="${style.linkTitle ?? ''}">$result</a>';
    }
    if (style.headerLevel != null) {
      result = '<h${style.headerLevel}>$result</h${style.headerLevel}>';
    }
    if (style.isBlockquote) {
      result = '<blockquote>$result</blockquote>';
    }
    if (style.isImage) {
      result =
          '<img src="${style.imageUrl ?? ''}" alt="${style.imageAlt ?? ''}" title="${style.imageTitle ?? ''}">';
    }
    if (style.isList) {
      final String listType = style.isOrderedList ? 'ol' : 'ul';
      result = '<$listType><li>$result</li></$listType>';
    }
    if (style.isCheckbox) {
      final String checked = style.checkboxStatus == true ? ' checked' : '';
      result = '<input type="checkbox"$checked> $result';
    }
    if (style.isHorizontalRule) {
      result = '<hr>';
    }
    if (style.isSuperscript) {
      result = '<sup>$result</sup>';
    }
    if (style.tableColumnAlignment != null) {
      final String align = style.tableColumnAlignment!;
      result = '<td align="$align">$result</td>';
    }
    if (style.isTableHeader) {
      result = '<th>$result</th>';
    }

    return result;
  }
}
