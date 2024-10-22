import 'package:equatable/equatable.dart';
import 'dart:math' as math;

import 'package:replay_bloc/replay_bloc.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_entity.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

part 'rich_text_event.dart';
part 'rich_text_state.dart';

class RichTextBloc extends ReplayBloc<RichTextEvent, RichTextState> {
  // final GetRichText getRichText;
  // final SaveRichText saveRichText;

  RichTextBloc(
      // {
      // required this.getRichText,
      // required this.saveRichText,
      //}
      )
      : super(RichTextState.initial()) {
    on<UpdateContentEvent>(_onUpdateContent);
    on<ApplyStyleEvent>(_onApplyStyle);
    on<LoadRichTextEvent>(_onLoadRichText);
    on<SaveRichTextEvent>(_onSaveRichText);
    on<InsertLinkEvent>(_onInsertLink);
    on<UnlinkEvent>(_onUnlink);
  }

  void _onUpdateContent(UpdateContentEvent event, Emitter<RichTextState> emit) {
    emit(state.loading);
    final newSpans = _updateSpansForContent(event.content);

    final newEntity = state.richTextEntity.copyWith(
      content: event.content,
      spans: newSpans,
    );

    emit(state.success.copyWith(richTextEntity: newEntity));
  }

  void _onApplyStyle(ApplyStyleEvent event, Emitter<RichTextState> emit) {
    emit(state.loading);
    var oldContent = state.richTextEntity.content;
    final start = event.start;
    final end = event.end;

    if (start == end) {
      emit(state.success);
      return;
    }

    final newSpans = _applyStyleToSpans(
      state.richTextEntity.spans,
      event.style,
      event.start,
      event.end,
    );

    final newEntity = state.richTextEntity.copyWith(
      content: oldContent,
      spans: newSpans,
    );

    emit(state.success.copyWith(richTextEntity: newEntity));
  }

  Future<void> _onLoadRichText(LoadRichTextEvent event, Emitter<RichTextState> emit) async {
    // emit(state.loading);
    // final result = await getRichText(event.id);
    // if (result.failure != null) {
    //   emit(state.failure.copyWith(message: 'Failed to load rich text: ${result.failure!}'));
    // } else if (result.value != null) {
    //   emit(state.success.copyWith(richTextEntity: result.value));
    // } else {
    //   emit(state.failure.copyWith(message: 'Unknown error occurred while loading rich text'));
    // }
  }

  Future<void> _onSaveRichText(SaveRichTextEvent event, Emitter<RichTextState> emit) async {
    // emit(state.loading);
    // final result = await saveRichText(state.richTextEntity);
    // if (result.failure != null) {
    //   emit(state.failure.copyWith(message: 'Failed to save rich text: ${result.failure!}'));
    // } else {
    //   emit(state.success.copyWith(message: 'Rich text saved successfully'));
    // }
  }

  void _onInsertLink(InsertLinkEvent event, Emitter<RichTextState> emit) {
    emit(state.loading);
    final RichTextEntity currentEntity = state.richTextEntity;
    final String currentContent = currentEntity.content;

    // Ensure start and end are within valid range
    final int safeStart = event.start.clamp(0, currentContent.length);
    final int safeEnd = event.end.clamp(safeStart, currentContent.length);

    String newContent;
    List<RichTextSpan> newSpans;

    if (safeStart == safeEnd) {
      // Insert new text if no selection
      newContent = currentContent.replaceRange(safeStart, safeEnd, event.text);
      final int insertedTextEnd = safeStart + event.text.length;

      newSpans = [
        ...currentEntity.spans.where((span) => span.end <= safeStart),
        RichTextSpan(
          start: safeStart,
          end: insertedTextEnd,
          style: RichTextStyle(isLink: true, linkUrl: event.url),
          originalLinkStart: safeStart,
          originalLinkEnd: insertedTextEnd,
        ),
        ...currentEntity.spans.where((span) => span.start >= safeEnd).map((span) {
          return span.copyWith(
            start: span.start + event.text.length - (safeEnd - safeStart),
            end: span.end + event.text.length - (safeEnd - safeStart),
          );
        }),
      ];
    } else {
      // Apply link to existing selection
      newContent = currentContent;
      newSpans = currentEntity.spans.map((span) {
        if (span.end <= safeStart || span.start >= safeEnd) {
          return span;
        } else {
          return RichTextSpan(
            start: span.start < safeStart ? safeStart : span.start,
            end: span.end > safeEnd ? safeEnd : span.end,
            style: RichTextStyle(isLink: true, linkUrl: event.url),
            originalLinkStart: safeStart,
            originalLinkEnd: safeEnd,
          );
        }
      }).toList();
    }

    final updatedEntity = currentEntity.copyWith(
      content: newContent,
      spans: newSpans,
    );

    emit(state.success.copyWith(richTextEntity: updatedEntity));
  }

  void _onUnlink(UnlinkEvent event, Emitter<RichTextState> emit) {
    emit(state.loading);
    final newSpans = _removeLink(
      state.richTextEntity.spans,
      event.start,
      event.end,
    );
    final newEntity = state.richTextEntity.copyWith(spans: newSpans);
    emit(state.success.copyWith(richTextEntity: newEntity));
  }

  List<RichTextSpan> _removeLink(List<RichTextSpan> spans, int start, int end) {
    final newSpans = <RichTextSpan>[];

    for (final span in spans) {
      if (span.style.isLink &&
          span.originalLinkStart != null &&
          span.originalLinkEnd != null &&
          ((start >= span.originalLinkStart! && start < span.originalLinkEnd!) ||
              (end > span.originalLinkStart! && end <= span.originalLinkEnd!))) {
        // Remove link style for the entire original link range
        newSpans.add(RichTextSpan(
          start: span.start,
          end: span.end,
          style: span.style.copyWith(isLink: false, linkUrl: null, linkTitle: null),
          originalLinkStart: null,
          originalLinkEnd: null,
        ));
      } else {
        newSpans.add(span);
      }
    }

    return _mergeAdjacentSpans(newSpans);
  }

  List<RichTextSpan> _mergeAdjacentSpans(List<RichTextSpan> spans) {
    if (spans.length <= 1) return spans;

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

    return mergedSpans;
  }

  List<RichTextSpan> _applyStyleToSpans(
    List<RichTextSpan> spans,
    RichTextStyle style,
    int start,
    int end, {
    int? originalLinkStart,
    int? originalLinkEnd,
    bool forceApply = false,
  }) {
    final newSpans = <RichTextSpan>[];

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
        final newStyle = forceApply ? style : _toggleStyle(span.style, style);

        newSpans.add(
          RichTextSpan(
            start: styledStart,
            end: styledEnd,
            style: newStyle,
            originalLinkStart: newStyle.isLink ? (originalLinkStart ?? styledStart) : null,
            originalLinkEnd: newStyle.isLink ? (originalLinkEnd ?? styledEnd) : null,
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

    return _mergeAdjacentSpans(
      _fillGapsWithDefaultStyle(
        newSpans,
        state.richTextEntity.content.length,
      ),
    );
  }

  List<RichTextSpan> _fillGapsWithDefaultStyle(List<RichTextSpan> spans, int contentLength) {
    spans.sort((a, b) => a.start.compareTo(b.start));
    final filledSpans = <RichTextSpan>[];
    int lastEnd = 0;

    for (final span in spans) {
      if (span.start > lastEnd) {
        filledSpans
            .add(RichTextSpan(start: lastEnd, end: span.start, style: const RichTextStyle()));
      }
      filledSpans.add(span);
      lastEnd = span.end;
    }

    if (lastEnd < contentLength) {
      filledSpans
          .add(RichTextSpan(start: lastEnd, end: contentLength, style: const RichTextStyle()));
    }

    return filledSpans;
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

  // bool _isStyleActiveInRange(int start, int end, bool Function(RichTextStyle) styleChecker) {
  //   for (final span in state.richTextEntity.spans) {
  //     if ((span.start <= start && span.end > start) || (span.start < end && span.end >= end)) {
  //       if (styleChecker(span.style)) {
  //         return true;
  //       }
  //     }
  //   }
  //   return false;
  // }

  List<RichTextSpan> _updateSpansForContent(String newContent) {
    final spans = state.richTextEntity.spans;
    final oldContent = state.richTextEntity.content;

    final List<RichTextSpan> updatedSpans = [];
    int oldIndex = 0;
    int newIndex = 0;

    for (final span in spans) {
      if (span.end <= oldIndex) {
        // Span is before any changes
        updatedSpans.add(span);
        continue;
      }

      if (span.start >= oldContent.length) {
        // Span is after the end of the old content
        break;
      }

      final spanText = oldContent.substring(span.start, span.end);
      final newStart = newContent.indexOf(spanText, newIndex);

      if (newStart != -1) {
        // Span text found in new content
        final newEnd = newStart + spanText.length;

        updatedSpans.add(
          RichTextSpan(
            start: newStart,
            end: newEnd,
            style: span.style,
            originalLinkStart: span.style.isLink ? newStart : null,
            originalLinkEnd: span.style.isLink ? newEnd : null,
          ),
        );
        newIndex = newEnd;
        oldIndex = span.end;
      } else if (span.style.isLink) {
        // Link span not found in new content, remove the link
        final remainingText = oldContent.substring(span.start);
        final newStart = newContent.indexOf(remainingText, newIndex);
        if (newStart != -1) {
          final newEnd = newStart + remainingText.length;
          updatedSpans.add(RichTextSpan(
            start: newStart,
            end: newEnd,
            style: span.style,
            originalLinkStart: null,
            originalLinkEnd: null,
          ));
          newIndex = newEnd;
          oldIndex = oldContent.length;
        }
      }
    }

    // Add any remaining unstyled text
    if (newIndex < newContent.length) {
      updatedSpans.add(RichTextSpan(
        start: newIndex,
        end: newContent.length,
        style: const RichTextStyle(),
      ));
    }

    return _mergeAdjacentSpans(updatedSpans);
  }
}
