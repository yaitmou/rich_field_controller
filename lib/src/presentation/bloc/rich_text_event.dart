part of 'rich_text_bloc.dart';

abstract class RichTextEvent extends Equatable implements ReplayEvent {
  const RichTextEvent();

  @override
  List<Object?> get props => [];
}

class UpdateContentEvent extends RichTextEvent {
  final String content;
  final List<RichTextSpan>? spans;

  const UpdateContentEvent(this.content, [this.spans]);

  @override
  List<Object?> get props => [content, spans];
}

class ApplyStyleEvent extends RichTextEvent {
  final RichTextStyle style;
  final int start;
  final int end;

  const ApplyStyleEvent(this.style, this.start, this.end);

  @override
  List<Object?> get props => [style, start, end];
}

class LoadRichTextEvent extends RichTextEvent {
  final String id;

  const LoadRichTextEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SaveRichTextEvent extends RichTextEvent {
  const SaveRichTextEvent();
}

class CaretRequested extends RichTextEvent {
  final CaretParams params;
  const CaretRequested(this.params);
  @override
  List<Object?> get props => [params];
}
