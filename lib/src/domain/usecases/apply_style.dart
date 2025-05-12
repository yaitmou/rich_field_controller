import 'package:equatable/equatable.dart';
import 'dart:math' as math;

import 'package:rich_field_controller/src/core/usecase/usecase.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_entity.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

class ApplyStyleParams extends Equatable {
  final RichTextStyle style;
  final int start;
  final int end;
  final bool forceApply;
  final RichTextEntity richTextEntity;

  const ApplyStyleParams({
    required this.style,
    required this.start,
    required this.end,
    required this.richTextEntity,
    this.forceApply = false,
  });
  @override
  List<Object?> get props => [
        richTextEntity,
        style,
        start,
        end,
      ];
}

class ApplyStyle implements UseCase<RichTextEntity, ApplyStyleParams> {
  @override
  call(ApplyStyleParams params) {
    var newSpans = <RichTextSpan>[];
    final style = params.style;
    final start = params.start;
    final end = params.end;
    final spans = params.richTextEntity.spans;
    final content = params.richTextEntity.content;

    bool styleApplied = false;

    for (final span in spans) {
      if (span.end <= start) {
        // Span is before the selection
        newSpans.add(span);
      } else if (span.start >= end) {
        // Span is after the selection
        newSpans.add(span);
      } else {
        // Span overlaps with the selection
        if (span.start < start) {
          // Add unchanged part before selection
          newSpans.add(span.copyWith(end: start));
        }

        // Add styled part within selection
        final styledStart = math.max(span.start, start);
        final styledEnd = math.min(span.end, end);
        final newStyle = params.forceApply ? style : _toggleStyle(span.style, style);

        newSpans.add(
          RichTextSpan(
            start: styledStart,
            end: styledEnd,
            style: newStyle,
          ),
        );
        styleApplied = true;

        if (span.end > end) {
          // Add unchanged part after selection
          newSpans.add(span.copyWith(start: end));
        }
      }
    }

    if (!styleApplied) {
      // If no existing span was modified, add a new span for the selection
      newSpans.add(RichTextSpan(
        start: start,
        end: end,
        style: style,
        originalLinkStart: style.isLink ? start : null,
        originalLinkEnd: style.isLink ? end : null,
      ));
    }

    // Merge adjacent spans with the same style
    var updatedRichTextEntity = params.richTextEntity
        .copyWith(
          content: content,
          spans: newSpans,
        )
        .fillGapsWithDefaultStyle()
        .mergeAdjacentSpans();

    return Future.value((
      failure: null,
      value: updatedRichTextEntity,
    ));
  }

  RichTextStyle _toggleStyle(RichTextStyle existingStyle, RichTextStyle newStyle) {
    return RichTextStyle(
      isBold: newStyle.isBold ? !existingStyle.isBold : existingStyle.isBold,
      isItalic: newStyle.isItalic ? !existingStyle.isItalic : existingStyle.isItalic,
      isStrikethrough:
          newStyle.isStrikethrough ? !existingStyle.isStrikethrough : existingStyle.isStrikethrough,
      isUnderline: newStyle.isUnderline ? !existingStyle.isUnderline : existingStyle.isUnderline,
      isCode: newStyle.isCode ? !existingStyle.isCode : existingStyle.isCode,
      isLink: newStyle.isLink ? !existingStyle.isLink : existingStyle.isLink,
      linkUrl: newStyle.isLink ? (newStyle.linkUrl ?? existingStyle.linkUrl) : null,
      linkTitle: newStyle.isLink ? (newStyle.linkTitle ?? existingStyle.linkTitle) : null,
      headerLevel: newStyle.headerLevel ?? existingStyle.headerLevel,
      // Add other style properties as needed
    );
  }
}
