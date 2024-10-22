import 'package:flutter/material.dart';
import 'package:rich_field_controller/src/controllers/_spans_generator.dart';
import 'package:rich_field_controller/src/convertors/html_converter.dart';
import 'package:rich_field_controller/src/convertors/markdown_convertor.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_entity.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';
import 'package:rich_field_controller/src/domain/entities/tags/markdown_tags.dart';
import 'package:rich_field_controller/src/presentation/bloc/rich_text_bloc.dart';

class RichTextEditingController extends TextEditingController {
  final BuildContext context;
  late final RichTextBloc bloc;
  String? initialText;

  late final SpansGenerator _spansGenerator;
  bool _isAtFirstLine = true;
  bool _isAtLastLine = true;

  int? caretInitialOffset;
  Offset caretInitialRawOffset = Offset.zero;
  bool _initPosition = false;
  bool caretAtStart = false;
  TextPainter? _painter;

  double? textFieldWidth;

  RichTextEditingController({
    required this.context,
    // required this.bloc,
    this.textFieldWidth = 0,
    this.initialText,
  }) {
    bloc = RichTextBloc();
    _spansGenerator = SpansGenerator(context);
    _initializeController();
  }

  void _initializeController() {
    // Listen for bloc stream and call listeners (defined below)
    bloc.stream.listen((state) {
      notifyListeners();
    });
    if (initialText != null) {
      bloc.add(UpdateContentEvent(initialText!));
    }

    addListener(() {
      // Run only if we are not loading and not in a failing state
      if (bloc.state.isReady && initialText != null) {
        text = initialText!;
        bloc.add(UpdateContentEvent(text));
        initialText = null;
      } else if (bloc.state.isReady && text != bloc.state.richTextEntity.content) {
        // We are parsing the entire document every time a change happens
        bloc.add(UpdateContentEvent(text));
      }
    });
  }

  bool get isAtLastLine => _isAtFirstLine;

  bool get isAtFirstLine => _isAtLastLine;

  // here we should the caret pixel x position!
  // this position should be converted to offset at te caret receiver side!
  double get caretPosition {
    if (_painter != null) {
      final lines = _painter!.computeLineMetrics();
      if (lines.isNotEmpty) {
        final caretOffset = _painter!.getOffsetForCaret(
          TextPosition(offset: selection.baseOffset),
          Rect.zero,
        );
        selection = TextSelection.collapsed(
          offset: _painter!.getPositionForOffset(caretInitialRawOffset).offset,
        );
        return caretOffset.dx;
      } else {
        return 0.0;
      }
    } else {
      return 0.0;
    }
  }

  void setCaretAt(double caretOffsetX, [bool insertAtStart = false]) {
    if (insertAtStart) {
      caretInitialRawOffset = Offset(caretOffsetX, 0);
    } else {
      if (_painter != null && value.text.isNotEmpty) {
        final lines = _painter!.computeLineMetrics();
        if (lines.isNotEmpty) {
          final lastLineHeight = lines.last.lineNumber * lines.last.height;
          caretInitialRawOffset = Offset(caretOffsetX, lastLineHeight);
        }
      }
    }
    _initPosition = true;
  }

  @override
  set value(TextEditingValue newValue) {
    super.value = newValue;
    for (var tag in MarkdownTags.values) {
      if (newValue.text.length > bloc.state.richTextEntity.content.length) {
        int startAt = 0;
        startAt = _parseMarkdownTags(newValue, tag, startAt);
      }
    }
  }

  /// this is called whenever new characters are entered. It looks for the inline tags and style the
  /// surrounded text accordingly.
  int _parseMarkdownTags(TextEditingValue value, MarkdownTags tag, int startAt) {
    String text = value.text;
    final openingTag = tag.openingTag;
    final openingTagLength = tag.openingTagLength;
    final closingTag = tag.closingTag;
    final closingTagLength = tag.closingTagLength;
    final style = tag.style;

    int startIndex = startAt;
    bool madeChange = false;

    int openTagPosition = text.indexOf(openingTag, 0);
    if (openTagPosition == -1) {
      return startAt;
    }

    int closeTagPosition = text.indexOf(closingTag, openTagPosition + openingTagLength);
    if (closeTagPosition == -1) {
      return startAt;
    }

    String surroundedText = text.substring(openTagPosition + openingTagLength, closeTagPosition);
    // make sure we do not trigger formatting unless we move out of the last tag
    final cursor = value.selection.baseOffset;
    if (surroundedText.isEmpty || cursor > (closeTagPosition + closingTagLength)) {
      return startAt;
    }

    // Remove surrounding characters
    // Warning: we should remove the last tag first

    text = text.replaceRange(closeTagPosition, closeTagPosition + closingTagLength, '');
    text = text.replaceRange(openTagPosition, openTagPosition + openingTagLength, '');
    // after removing characters we should shit the text's position (from the style POV)
    final newStartTextPos = openTagPosition;
    final newEndTextPos = openTagPosition + surroundedText.length;

    madeChange = true;
    startIndex = openTagPosition + surroundedText.length;

    bloc
      ..add(UpdateContentEvent(text))
      ..add(
        ApplyStyleEvent(
          style,
          newStartTextPos,
          newEndTextPos,
        ),
      );
    if (madeChange) {
      // In this bloc we want to move the cursor to the end of the formatted text
      int newCursorPosition = value.selection.baseOffset - 2 * closingTagLength;
      if (newCursorPosition < 0) newCursorPosition = 0;
      this.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );
    }

    return startIndex;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    //Loop over the styles to get the spans' styles Create TextPaint and get e width
    final spans = _buildTextSpan(bloc.state.richTextEntity, style);

    ///
    ///
    ///
    ///
    ///

    _painter = TextPainter(
      text: spans,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    _painter!.layout(maxWidth: textFieldWidth!);

    final caretOffset = _painter!.getOffsetForCaret(
      TextPosition(offset: selection.baseOffset),
      Rect.zero,
    );
    final lines = _painter!.computeLineMetrics();

    const tolerance = 0.5;
    if (lines.isEmpty) {
      _isAtFirstLine = true;
    } else {
      _isAtFirstLine = caretOffset.dy.abs() < tolerance;
    }

    if (lines.isNotEmpty) {
      final lastMetric = lines.last;
      _isAtLastLine = caretOffset.dy + tolerance > lastMetric.height * lastMetric.lineNumber;
    }

    ///
    ///
    ///
    ///

    if (_initPosition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        int caretInitialOffset = -1;
        if (value.text.isEmpty) {
          caretInitialOffset = -1;
        } else if (_painter != null) {
          caretInitialOffset = _painter!.getPositionForOffset(caretInitialRawOffset).offset;
        }
        selection = TextSelection.collapsed(offset: caretInitialOffset);
        _initPosition = false;
      });
    }

    return spans;
  }

  TextSpan _buildTextSpan(
    RichTextEntity richTextEntity,
    TextStyle? baseStyle,
  ) {
    String content = richTextEntity.content;
    List<RichTextSpan> spans = richTextEntity.spans;
    final List<InlineSpan> children = [];

    // If nothing is styled set all to baseStyle that should be provided by the textField
    if (spans.isEmpty) {
      return TextSpan(text: content, style: baseStyle);
    }

    // Prepare for inline spans construction

    int lastIndex = 0;

    for (final span in spans) {
      // If we are styling the middle of the content [lastIndex ... span.start], the previous text
      // gets the baseStyle.
      if (span.start > lastIndex) {
        // get the sub content
        final subContent = content.substring(lastIndex, span.start);
        children.add(TextSpan(text: subContent, style: baseStyle));
      }

      // we add the textSpan between start and end base on the style provide in the richTextSpan
      // span
      final generatedSpan = _spansGenerator.generateSpan(
        text: content.substring(span.start, span.end),
        style: span.style,
        baseStyle: baseStyle,
      );

      children.add(generatedSpan);
      lastIndex = span.end;
    }

    // We we don't have an other richSpan we apply baseStyle to the remaining of the text
    if (lastIndex < content.length) {
      children.add(TextSpan(text: content.substring(lastIndex), style: baseStyle));
    }

    return TextSpan(style: baseStyle, children: children);
  }

  /// Public API
  void toggleBold() {
    _applyStyle(const RichTextStyle(isBold: true));
  }

  void toggleItalic() {
    _applyStyle(const RichTextStyle(isItalic: true));
  }

  void toggleStrikethrough() {
    _applyStyle(const RichTextStyle(isStrikethrough: true));
  }

  void toggleUnderline() {
    _applyStyle(const RichTextStyle(isUnderline: true));
  }

  void toggleCode() {
    _applyStyle(const RichTextStyle(isCode: true));
  }

  void toggleListItem() {
    _addFormatTag('  \u2022 ');
  }

  void applyHeaderStyle(
    int start,
    int end,
    int level,
  ) {
    // final style = RichTextStyle(headerLevel: level);
    // bloc.add(ApplyStyleEvent(style, start, end));
    final style = RichTextStyle(headerLevel: level);

    // Add a newline before the header if it's not at the start of the text
    // if (start > 0 && text[start - 1] != '\n') {
    //   text = text.replaceRange(start, start, '\n');
    //   end += 1;
    // }

    // // Add a newline after the header if it's not at the end of the text
    // if (end < text.length && text[end] != '\n') {
    //   text = text.replaceRange(end, end, '\n');
    // }
    // final endIndex = text.indexOf('\n', start);
    bloc.add(ApplyStyleEvent(style, start, end));
  }

  void toggleHeader(int level) {
    _addFormatTag('${'#' * level} ');
  }

  void undo() {
    bloc.undo();
  }

  void redo() {
    bloc.redo();
  }

  String toHtml() {
    return HtmlConverter.convertToHtml(bloc.state.richTextEntity);
  }

  String toMarkdown() {
    return MarkdownConverter.convertToMarkdown(bloc.state.richTextEntity);
  }

  // Turn a new line into a list item
  // This should be called when we hit the 'list' tool button
  void _addFormatTag(String tag) {
    final String text = value.text;
    final TextSelection selection = value.selection;
    final int cursorPosition = selection.baseOffset;

    if (cursorPosition < 0 || text.isEmpty) {
      return;
    }

    int lineStart;
    if (cursorPosition == 0) {
      lineStart = 0;
    } else {
      lineStart = text.lastIndexOf('\n', cursorPosition - 1) + 1;
    }

    final int lineEnd = text.indexOf('\n', cursorPosition);
    final String currentLine =
        lineEnd == -1 ? text.substring(lineStart) : text.substring(lineStart, lineEnd);

    // Check if the line already starts with a bullet point (including padding)
    if (!currentLine.startsWith(tag)) {
      final String newText = text.replaceRange(lineStart, lineStart, tag);
      final int newCursorPosition = cursorPosition + tag.length;

      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );
    }
  }

// used to decide wither or not to show the link button
  bool get canLink => selection.baseOffset != selection.extentOffset;

  void insertLink(String text, String url) {
    final TextSelection selection = this.selection;
    final int start = selection.baseOffset;
    final int end = selection.extentOffset;
    final String selectedText = selection.textInside(this.text);

    if (selectedText.isNotEmpty) {
      // If text is selected, make it a link
      bloc.add(InsertLinkEvent(selectedText, url, start, end));
    }
  }

  String getSelectedText() {
    return selection.textInside(text);
  }

  void removeLink() {
    final TextSelection selection = this.selection;
    final RichTextEntity richTextEntity = bloc.state.richTextEntity;

    // Find the link span that contains the cursor or selection
    final linkSpan = richTextEntity.spans.firstWhere(
      (span) =>
          span.style.isLink &&
          span.originalLinkStart != null &&
          span.originalLinkEnd != null &&
          ((span.originalLinkStart! <= selection.start &&
                  selection.start < span.originalLinkEnd!) ||
              (span.originalLinkStart! < selection.end && selection.end <= span.originalLinkEnd!)),
      orElse: () => const RichTextSpan(start: -1, end: -1, style: RichTextStyle()),
    );

    if (linkSpan.start != -1) {
      // If a link span is found, remove the link for the entire original link range
      bloc.add(UnlinkEvent(linkSpan.originalLinkStart!, linkSpan.originalLinkEnd!));
    } else if (!selection.isCollapsed) {
      // If there's a selection but it's not entirely within a link, remove any links within the selection
      bloc.add(UnlinkEvent(selection.start, selection.end));
    }
  }

  void _applyStyle(RichTextStyle style, [TextSelection? initialSelection]) {
    final TextSelection selection = initialSelection ?? this.selection;
    bloc.add(ApplyStyleEvent(style, selection.start, selection.end));
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}
