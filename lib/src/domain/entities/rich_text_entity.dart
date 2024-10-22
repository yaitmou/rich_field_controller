import 'package:equatable/equatable.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';

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

  @override
  List<Object?> get props => [id, content, spans];
}
