import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

class SpansGenerator {
  final BuildContext context;
  late final ThemeData theme;
  SpansGenerator(this.context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      theme = Theme.of(context);
    });
  }

  InlineSpan generateSpan({
    required String text,
    required RichTextStyle style,
    TextStyle? baseStyle,
  }) {
    // if (style.isBlockquote) {
    //   return WidgetSpan(
    //     child: EditableCodeBlock(
    //       initialCode: text,
    //       onChanged: (value) {
    //         print(value);
    //       },
    //       textStyle: baseStyle ?? const TextStyle(),
    //     ),
    //   );
    // }

    return TextSpan(
      text: text,
      style: _styleBuilder(style, baseStyle ?? const TextStyle()),
      recognizer: style.isLink ? _createTapGestureRecognizer(style.linkUrl) : null,
    );
  }

  TextStyle _styleBuilder(RichTextStyle richTextStyle, TextStyle baseStyle) {
    TextStyle style = baseStyle;
    // final theme = Theme.of(context);

    // code
    if (richTextStyle.isCode) {
      style = theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.surface,
        backgroundColor: theme.colorScheme.onSurface,
        fontFamily: 'monospace',
        fontSize: theme.textTheme.bodyMedium!.fontSize!,
      );
      style = style.copyWith(
        background: Paint()
          ..color = theme.hintColor
          ..style = PaintingStyle.fill
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    } else if (richTextStyle.headerLevel == 1) {
      style = theme.textTheme.headlineLarge!;
    } else if (richTextStyle.headerLevel == 2) {
      style = theme.textTheme.headlineMedium!;
    } else if (richTextStyle.headerLevel == 3) {
      style = theme.textTheme.headlineSmall!;
    } else if (richTextStyle.headerLevel == 4) {
      style = theme.textTheme.titleLarge!;
    } else if (richTextStyle.headerLevel == 5) {
      style = theme.textTheme.titleMedium!;
    } else if (richTextStyle.headerLevel == 6) {
      style = theme.textTheme.titleSmall!;
    } else {
      // Bold
      if (richTextStyle.isBold) {
        style = style.copyWith(fontWeight: FontWeight.bold);
      }
      // Italic
      if (richTextStyle.isItalic) {
        style = style.copyWith(fontStyle: FontStyle.italic);
      }
      // StrikeThrough
      if (richTextStyle.isStrikethrough) {
        style = style.copyWith(decoration: TextDecoration.lineThrough);
      }
      // StrikeThrough
      if (richTextStyle.isUnderline) {
        style = style.copyWith(decoration: TextDecoration.underline);
      }

      // link
      if (richTextStyle.isLink) {
        style = style.copyWith(decoration: TextDecoration.underline, color: Colors.blue);
      }
    }

    return style;
  }

  GestureRecognizer? _createTapGestureRecognizer(String? url) {
    if (url == null) return null;
    return TapGestureRecognizer()
      ..onTap = () {
        // Handle link tap
        // this should be uniform across all anchors: open url through url_launcher...
      };
  }
}
