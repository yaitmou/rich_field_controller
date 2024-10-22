import 'package:equatable/equatable.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

class RichTextSpan extends Equatable {
  // character position where style starts
  final int start;
  // character position where style ends
  final int end;
  // Style to apply to this range [start...end]
  // each Text span can have only one character
  final RichTextStyle style;
  // link start and end
  // specific for link insertion!
  final int? originalLinkStart;
  final int? originalLinkEnd;

  const RichTextSpan({
    required this.start,
    required this.end,
    required this.style,
    this.originalLinkStart,
    this.originalLinkEnd,
  });

  RichTextSpan copyWith({
    int? start,
    int? end,
    RichTextStyle? style,
    int? originalLinkStart,
    int? originalLinkEnd,
  }) {
    return RichTextSpan(
      start: start ?? this.start,
      end: end ?? this.end,
      style: style ?? this.style,
      originalLinkStart: originalLinkStart ?? this.originalLinkStart,
      originalLinkEnd: originalLinkEnd ?? this.originalLinkEnd,
    );
  }

  @override
  List<Object?> get props => [
        start,
        end,
        style,
        originalLinkStart,
        originalLinkEnd,
      ];
}
