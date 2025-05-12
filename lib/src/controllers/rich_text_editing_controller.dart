import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rich_field_controller/injection_container.dart';
import 'package:rich_field_controller/src/controllers/_spans_generator.dart';
import 'package:rich_field_controller/src/controllers/formatters/bullet_formatter.dart';
import 'package:rich_field_controller/src/controllers/formatters/header_formatter.dart';
import 'package:rich_field_controller/src/controllers/formatters/inline_markdown_formatter.dart';
import 'package:rich_field_controller/src/controllers/formatters/link_formatter.dart';
import 'package:rich_field_controller/src/controllers/formatters/number_list_formatter.dart';
import 'package:rich_field_controller/src/convertors/html_converter.dart';
import 'package:rich_field_controller/src/convertors/markdown_convertor.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_entity.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';
import 'package:rich_field_controller/src/domain/usecases/get_caret.dart';
import 'package:rich_field_controller/src/presentation/bloc/rich_text_bloc.dart';

class RichTextEditingController extends TextEditingController {
  final BuildContext context;
  String? initialText;

  late final SpansGenerator _spansGenerator;
  bool _isAtFirstLine = true;
  bool _isAtLastLine = true;

  int? caretInitialOffset;
  Offset caretInitialRawOffset = Offset.zero;
  bool _initPosition = false;
  bool caretAtStart = false;
  TextPainter? _painter;

  /// formatters
  late final LinkFormatter _linkFormatter;
  late final HeaderFormatter _headerFormatter;
  late final InlineMarkdownFormatter _inlineMarkdownFormatter;
  final GlobalKey textFieldKey;

  // the bloc
  RichTextBloc bloc = sl<RichTextBloc>();

  RichTextEditingController({
    required this.context,
    required this.textFieldKey,
    this.initialText,
  }) {
    _initializeController();

    _spansGenerator = SpansGenerator(context);

    // link formatter
    _linkFormatter = LinkFormatter(
      onLinkFound: (text, url, start, end) {
        WidgetsBinding.instance.addPostFrameCallback((d) {
          final urlStyle = RichTextStyle(
            isLink: true,
            linkUrl: url,
          );
          bloc.add(ApplyStyleEvent(urlStyle, start, end));
        });
      },
    );

    // Header formatter
    _headerFormatter = HeaderFormatter(
      onHeaderCommand: (command) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          bloc.add(ApplyStyleEvent(command.style, command.start, command.end));
        });
      },
    );

    // In the constructor, initialize the formatter
    _inlineMarkdownFormatter = InlineMarkdownFormatter(
      onStyleFound: (style, start, end) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          bloc.add(ApplyStyleEvent(style, start, end));
        });
      },
    );
  }
  void _initializeController() async {
    // await initRichTextEditingController();
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
      bloc.add(
        CaretRequested(
          CaretParams(
            painter: _painter!,
            selection: selection,
          ),
        ),
      );
      final caret = bloc.state.caretEntity;

      return caret?.xPosition ?? 0.0;
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
    ///

    _painter = TextPainter(
      text: spans,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    final RenderBox? renderBox = textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final textFieldWidth = renderBox?.size.width;
    _painter!.layout(maxWidth: textFieldWidth ?? 0.0);

    // final caretOffset = _painter!.getOffsetForCaret(
    //   TextPosition(offset: selection.baseOffset),
    //   Rect.zero,
    // );

    // final lines = _painter!.computeLineMetrics();

    // const tolerance = 0.5;
    // if (lines.isEmpty) {
    //   _isAtFirstLine = true;
    // } else {
    //   _isAtFirstLine = caretOffset.dy.abs() < tolerance;
    // }

    // if (lines.isNotEmpty) {
    //   final lastMetric = lines.last;
    //   _isAtLastLine = caretOffset.dy + tolerance > lastMetric.height * lastMetric.lineNumber;
    // }

    ///
    ///
    ///
    ///

    // if (_initPosition) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     int caretInitialOffset = -1;
    //     if (value.text.isEmpty) {
    //       caretInitialOffset = -1;
    //     } else if (_painter != null) {
    //       caretInitialOffset = _painter!.getPositionForOffset(caretInitialRawOffset).offset;
    //     }
    //     selection = TextSelection.collapsed(offset: caretInitialOffset);
    //     _initPosition = false;
    //   });
    // }

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

  /// Formatters

  // Add formatter to the list of formatters
  List<TextInputFormatter> get formatters => [
        //
        //The below formatter do not apply any styling
        BulletPointFormatter(),
        NumberListFormatter(),
        //
        // the below formatters apply styling...
        _linkFormatter,
        // _headerFormatter,
        _inlineMarkdownFormatter,
      ];

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
    final String text = value.text;
    final TextSelection selection = value.selection;

    // If no text is selected, just add a single bullet point
    if (selection.baseOffset == selection.extentOffset) {
      _addFormatTag('  \u2022 ');
      return;
    }

    // Get the actual start and end positions accounting for selection direction
    final int selectionStart = selection.start;
    final int selectionEnd = selection.end;

    // Get the start of the first line in selection
    int lineStart;
    if (selectionStart == 0) {
      lineStart = 0;
    } else {
      lineStart = text.lastIndexOf('\n', selectionStart - 1) + 1;
    }

    // Get the end of the last line in selection
    int lineEnd = text.indexOf('\n', selectionEnd);
    if (lineEnd == -1) {
      lineEnd = text.length;
    } else {
      lineEnd += 1; // Include the newline character
    }

    // Validate ranges
    lineStart = lineStart.clamp(0, text.length);
    lineEnd = lineEnd.clamp(lineStart, text.length);

    // Split the selected text into lines
    String selectedText = text.substring(lineStart, lineEnd);
    List<String> lines = selectedText.split('\n');

    // Build bullet point list
    String newText = '';

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      // Skip empty lines
      if (line.isEmpty) {
        newText += '\n';
        continue;
      }

      // Remove existing list markers if any
      line = line.replaceFirst(RegExp(r'^\s*\d+\.\s*'), ''); // Remove numbered list marker
      line = line.replaceFirst(RegExp(r'^\s*[•-]\s*'), ''); // Remove bullet point marker

      // Add new bullet point marker
      newText += '  \u2022 $line';

      // Add newline for all but the last line
      if (i < lines.length - 1) {
        newText += '\n';
      }
    }

    // Replace the text in the original string
    final String beforeSelection = text.substring(0, lineStart);
    final String afterSelection = lineEnd < text.length ? text.substring(lineEnd) : '';
    final String updatedText = beforeSelection + newText + afterSelection;

    // Calculate new cursor position
    final int newCursorPosition = lineStart + newText.length;

    value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  void toggleNumberedList() {
    final String text = value.text;
    final TextSelection selection = value.selection;

    // If no text is selected, just add a single number
    if (selection.baseOffset == selection.extentOffset) {
      _addFormatTag('  1. ');
      return;
    }

    // Get the actual start and end positions accounting for selection direction
    final int selectionStart = selection.start;
    final int selectionEnd = selection.end;

    // Get the start of the first line in selection
    int lineStart;
    if (selectionStart == 0) {
      lineStart = 0;
    } else {
      lineStart = text.lastIndexOf('\n', selectionStart - 1) + 1;
    }

    // Get the end of the last line in selection
    int lineEnd = text.indexOf('\n', selectionEnd);
    if (lineEnd == -1) {
      lineEnd = text.length;
    } else {
      lineEnd += 1; // Include the newline character
    }

    // Validate ranges
    lineStart = lineStart.clamp(0, text.length);
    lineEnd = lineEnd.clamp(lineStart, text.length);

    // Split the selected text into lines
    String selectedText = text.substring(lineStart, lineEnd);
    List<String> lines = selectedText.split('\n');

    // Build numbered list
    String newText = '';
    int number = 1;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      // Skip empty lines
      if (line.isEmpty) {
        newText += '\n';
        continue;
      }

      // Remove existing list markers if any
      line = line.replaceFirst(RegExp(r'^\s*\d+\.\s*'), '');
      line = line.replaceFirst(RegExp(r'^\s*[•-]\s*'), '');

      // Add new numbered list marker
      newText += '  $number. $line';

      // Add newline for all but the last line
      if (i < lines.length - 1) {
        newText += '\n';
      }

      number++;
    }

    // Replace the text in the original string
    final String beforeSelection = text.substring(0, lineStart);
    final String afterSelection = lineEnd < text.length ? text.substring(lineEnd) : '';
    final String updatedText = beforeSelection + newText + afterSelection;

    // Calculate new cursor position
    final int newCursorPosition = lineStart + newText.length;

    value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  void toggleHeader(int level) {
    _applyStyle(RichTextStyle(headerLevel: level));
    // _addFormatTag('${'#' * level} ');
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

  String getSelectedText() {
    return selection.textInside(text);
  }

  void _applyStyle(RichTextStyle style, [TextSelection? initialSelection]) {
    final TextSelection selection = initialSelection ?? this.selection;
    bloc.add(ApplyStyleEvent(style, selection.start, selection.end));
  }

  @override
  void dispose() {
    // bloc.close();
    super.dispose();
  }
}
