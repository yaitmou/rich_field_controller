part of 'rich_text_bloc.dart';

enum RichTextStatus { initial, loading, success, failure }

class RichTextState extends Equatable {
  final RichTextStatus status;
  final RichTextEntity richTextEntity;
  final String? message;

  const RichTextState({
    this.status = RichTextStatus.initial,
    required this.richTextEntity,
    this.message,
  });

  RichTextState get loading => copyWith(status: RichTextStatus.loading);
  RichTextState get success => copyWith(status: RichTextStatus.success);
  RichTextState get failure => copyWith(status: RichTextStatus.failure);

  bool get isInitial => status == RichTextStatus.initial;
  bool get isSuccess => status == RichTextStatus.success;
  bool get isReady => isInitial || isSuccess;

  RichTextState copyWith({
    RichTextStatus? status,
    RichTextEntity? richTextEntity,
    String? message,
  }) =>
      RichTextState(
        status: status ?? this.status,
        richTextEntity: richTextEntity ?? this.richTextEntity,
        message: message ?? this.message,
      );

  factory RichTextState.initial() => const RichTextState(
        richTextEntity: RichTextEntity(
          id: '',
          content: '',
          spans: [],
        ),
      );

  @override
  List<Object?> get props => [status, richTextEntity, message];
}
