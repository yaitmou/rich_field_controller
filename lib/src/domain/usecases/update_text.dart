import 'package:equatable/equatable.dart';
import 'dart:math' as math;

import 'package:rich_field_controller/src/core/usecase/usecase.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_entity.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

class UpdateRichTextContentParams extends Equatable {
  final String content;
  final RichTextEntity richTextEntity;

  const UpdateRichTextContentParams({
    required this.content,
    required this.richTextEntity,
  });
  @override
  List<Object?> get props => [content, richTextEntity];
}

class UpdateRichTextContent implements UseCase<RichTextEntity, UpdateRichTextContentParams> {
  @override
  call(UpdateRichTextContentParams params) {
    final spans = params.richTextEntity.spans;
    final oldContent = params.richTextEntity.content;
    final newContent = params.content;

    // Early return if no change
    if (oldContent == newContent) {
      return Future.value((
        failure: null,
        value: params.richTextEntity,
      ));
    }

    // Handle deletion case
    if (newContent.length < oldContent.length) {
      return Future.value((
        failure: null,
        value: _handleDeletion(
          oldContent: oldContent,
          newContent: newContent,
          spans: spans,
          richTextEntity: params.richTextEntity,
        ),
      ));
    }

    // Handle insertion case
    return Future.value((
      failure: null,
      value: _handleInsertion(
        oldContent: oldContent,
        newContent: newContent,
        spans: spans,
        richTextEntity: params.richTextEntity,
      ),
    ));

    // List<RichTextSpan> updatedSpans = [];
    // int oldIndex = 0;
    // int newIndex = 0;

    // for (final span in spans) {
    //   if (span.end <= oldIndex) {
    //     // Span is before any changes
    //     updatedSpans.add(span);
    //     continue;
    //   }

    //   if (span.start >= oldContent.length) {
    //     // Span is after the end of the old content
    //     break;
    //   }

    //   final spanText = oldContent.substring(span.start, span.end);
    //   final newStart = newContent.indexOf(spanText, newIndex);

    //   if (newStart != -1) {
    //     // Span text found in new content
    //     final newEnd = newStart + spanText.length;

    //     updatedSpans.add(
    //       RichTextSpan(
    //         start: newStart,
    //         end: newEnd,
    //         style: span.style,
    //         originalLinkStart: span.style.isLink ? newStart : null,
    //         originalLinkEnd: span.style.isLink ? newEnd : null,
    //       ),
    //     );
    //     newIndex = newEnd;
    //     oldIndex = span.end;
    //   } else if (span.style.isLink) {
    //     // Link span not found in new content, remove the link
    //     final remainingText = oldContent.substring(span.start);
    //     final newStart = newContent.indexOf(remainingText, newIndex);
    //     if (newStart != -1) {
    //       final newEnd = newStart + remainingText.length;
    //       updatedSpans.add(RichTextSpan(
    //         start: newStart,
    //         end: newEnd,
    //         style: span.style,
    //         originalLinkStart: null,
    //         originalLinkEnd: null,
    //       ));
    //       newIndex = newEnd;
    //       oldIndex = oldContent.length;
    //     }
    //   }
    // }

    // // Add any remaining unstyled text
    // if (newIndex < newContent.length) {
    //   updatedSpans.add(RichTextSpan(
    //     start: newIndex,
    //     end: newContent.length,
    //     style: const RichTextStyle(),
    //   ));
    // }

    // final updatedRichTextEntity = params.richTextEntity.copyWith(
    //   content: newContent,
    //   spans: updatedSpans,
    // );

    // return Future.value(
    //   (
    //     failure: null,
    //     value: updatedRichTextEntity.mergeAdjacentSpans(),
    //   ),
    // );
  }

  RichTextEntity _handleInsertion({
    required String oldContent,
    required String newContent,
    required List<RichTextSpan> spans,
    required RichTextEntity richTextEntity,
  }) {
    // Find insertion point and length
    int prefixLength = 0;
    int suffixLength = 0;

    // Find common prefix
    while (prefixLength < oldContent.length &&
        prefixLength < newContent.length &&
        oldContent[prefixLength] == newContent[prefixLength]) {
      prefixLength++;
    }

    // Find common suffix
    while (suffixLength < oldContent.length - prefixLength &&
        suffixLength < newContent.length - prefixLength &&
        oldContent[oldContent.length - 1 - suffixLength] ==
            newContent[newContent.length - 1 - suffixLength]) {
      suffixLength++;
    }

    final insertedLength = newContent.length - oldContent.length;
    final List<RichTextSpan> updatedSpans = [];

    // Sort spans by start position
    final sortedSpans = List<RichTextSpan>.from(spans)..sort((a, b) => a.start.compareTo(b.start));

    for (final span in sortedSpans) {
      if (span.end <= prefixLength) {
        // Span is completely before insertion point
        updatedSpans.add(span);
      } else if (span.start >= oldContent.length - suffixLength) {
        // Span is completely after insertion point
        updatedSpans.add(RichTextSpan(
          start: span.start + insertedLength,
          end: span.end + insertedLength,
          style: span.style,
          originalLinkStart:
              span.originalLinkStart != null ? span.originalLinkStart! + insertedLength : null,
          originalLinkEnd:
              span.originalLinkEnd != null ? span.originalLinkEnd! + insertedLength : null,
        ));
      } else if (span.start < prefixLength && span.end > oldContent.length - suffixLength) {
        // Span encompasses the insertion point
        updatedSpans.add(RichTextSpan(
          start: span.start,
          end: span.end + insertedLength,
          style: span.style,
          originalLinkStart: span.originalLinkStart,
          originalLinkEnd:
              span.originalLinkEnd != null ? span.originalLinkEnd! + insertedLength : null,
        ));
      } else if (span.start < prefixLength) {
        // Span starts before but ends in or after insertion point
        updatedSpans.add(RichTextSpan(
          start: span.start,
          end: span.end + insertedLength,
          style: span.style,
          originalLinkStart: span.originalLinkStart,
          originalLinkEnd:
              span.originalLinkEnd != null ? span.originalLinkEnd! + insertedLength : null,
        ));
      } else {
        // Span starts after insertion point
        updatedSpans.add(RichTextSpan(
          start: span.start + insertedLength,
          end: span.end + insertedLength,
          style: span.style,
          originalLinkStart:
              span.originalLinkStart != null ? span.originalLinkStart! + insertedLength : null,
          originalLinkEnd:
              span.originalLinkEnd != null ? span.originalLinkEnd! + insertedLength : null,
        ));
      }
    }

    return richTextEntity
        .copyWith(
          content: newContent,
          spans: updatedSpans,
        )
        .fillGapsWithDefaultStyle()
        .mergeAdjacentSpans();
  }

  RichTextEntity _handleDeletion({
    required String oldContent,
    required String newContent,
    required List<RichTextSpan> spans,
    required RichTextEntity richTextEntity,
  }) {
    // Find deletion boundaries by comparing old and new content
    int prefixLength = 0;
    int suffixLength = 0;

    // Find common prefix length
    while (prefixLength < newContent.length &&
        prefixLength < oldContent.length &&
        oldContent[prefixLength] == newContent[prefixLength]) {
      prefixLength++;
    }

    // Find common suffix length
    while (suffixLength < newContent.length - prefixLength &&
        suffixLength < oldContent.length - prefixLength &&
        oldContent[oldContent.length - 1 - suffixLength] ==
            newContent[newContent.length - 1 - suffixLength]) {
      suffixLength++;
    }

    // Calculate deletion region
    final deletionStart = prefixLength;
    final deletionEnd = oldContent.length - suffixLength;
    final deletedLength = deletionEnd - deletionStart;

    final List<RichTextSpan> updatedSpans = [];

    for (final span in spans) {
      // Span completely before deletion - keep unchanged
      if (span.end <= deletionStart) {
        updatedSpans.add(span);
        continue;
      }

      // Span completely after deletion - adjust position
      if (span.start >= deletionEnd) {
        updatedSpans.add(RichTextSpan(
          start: span.start - deletedLength,
          end: span.end - deletedLength,
          style: span.style,
          originalLinkStart:
              span.originalLinkStart != null ? span.originalLinkStart! - deletedLength : null,
          originalLinkEnd:
              span.originalLinkEnd != null ? span.originalLinkEnd! - deletedLength : null,
        ));
        continue;
      }

      // Span overlaps with deletion region
      final newStart = math.min(span.start, deletionStart);
      final newEnd = math.max(deletionStart, span.end - deletedLength);

      // Only add span if it still has length after deletion
      if (newEnd > newStart) {
        updatedSpans.add(RichTextSpan(
          start: newStart,
          end: newEnd,
          style: span.style,
          originalLinkStart:
              span.originalLinkStart != null ? math.min(span.originalLinkStart!, newEnd) : null,
          originalLinkEnd:
              span.originalLinkEnd != null ? math.min(span.originalLinkEnd!, newEnd) : null,
        ));
      }
    }

    return richTextEntity
        .copyWith(
          content: newContent,
          spans: updatedSpans,
        )
        .mergeAdjacentSpans();
  }
}
