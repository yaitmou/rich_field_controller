import 'package:equatable/equatable.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

class RichTextEntity extends Equatable {
  final String id;
  // all textfield text content
  final String content;
  // holds styles applied to portions of the content
  final List<RichTextSpan> spans;

  const RichTextEntity({
    required this.id,
    required this.content,
    required this.spans,
  });

  RichTextEntity copyWith({
    String? id,
    String? content,
    List<RichTextSpan>? spans,
  }) {
    return RichTextEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      spans: spans ?? this.spans,
    );
  }

  RichTextEntity fillGapsWithDefaultStyle() {
    var sortedSpans = spans.toList();
    sortedSpans.sort((a, b) => a.start.compareTo(b.start));
    final filledSpans = <RichTextSpan>[];
    int lastEnd = 0;

    for (final span in sortedSpans) {
      if (span.start > lastEnd) {
        filledSpans
            .add(RichTextSpan(start: lastEnd, end: span.start, style: const RichTextStyle()));
      }
      filledSpans.add(span);
      lastEnd = span.end;
    }

    if (lastEnd < content.length) {
      filledSpans
          .add(RichTextSpan(start: lastEnd, end: content.length, style: const RichTextStyle()));
    }

    return copyWith(spans: filledSpans);
  }

  RichTextEntity mergeAdjacentSpans() {
    if (spans.length <= 1) {
      return this;
    }

    final mergedSpans = <RichTextSpan>[spans.first];
    for (var i = 1; i < spans.length; i++) {
      final currentSpan = spans[i];
      final previousSpan = mergedSpans.last;

      if (previousSpan.end == currentSpan.start && previousSpan.style == currentSpan.style) {
        mergedSpans.last = RichTextSpan(
          start: previousSpan.start,
          end: currentSpan.end,
          style: previousSpan.style,
          originalLinkStart: previousSpan.originalLinkStart ?? currentSpan.originalLinkStart,
          originalLinkEnd: currentSpan.originalLinkEnd ?? previousSpan.originalLinkEnd,
        );
      } else {
        mergedSpans.add(currentSpan);
      }
    }

    return copyWith(spans: mergedSpans);
  }

  @override
  List<Object?> get props => [id, content, spans];
}
