import 'package:equatable/equatable.dart';

import 'package:replay_bloc/replay_bloc.dart';
import 'package:rich_field_controller/src/domain/entities/caret.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_entity.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_span.dart';
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';
import 'package:rich_field_controller/src/domain/usecases/apply_style.dart';
import 'package:rich_field_controller/src/domain/usecases/get_caret.dart';
import 'package:rich_field_controller/src/domain/usecases/update_text.dart';

part 'rich_text_event.dart';
part 'rich_text_state.dart';

class RichTextBloc extends ReplayBloc<RichTextEvent, RichTextState> {
  // final GetRichText getRichText;
  // final SaveRichText saveRichText;
  final ApplyStyle applyStyle;
  final UpdateRichTextContent updateRichTextContent;

  final GetCaret getCaret;

  RichTextBloc({
    // required this.getRichText,
    // required this.saveRichText,
    required this.getCaret,
    required this.applyStyle,
    required this.updateRichTextContent,
  }) : super(RichTextState.initial()) {
    on<UpdateContentEvent>(_onUpdateContent);
    on<ApplyStyleEvent>(_onApplyStyle);
    on<LoadRichTextEvent>(_onLoadRichText);
    on<SaveRichTextEvent>(_onSaveRichText);
    on<CaretRequested>(_onCaretRequested);
  }

  void _onUpdateContent(UpdateContentEvent event, Emitter<RichTextState> emit) async {
    emit(state.loading);

    final (failure: failure, value: newEntity) = await updateRichTextContent(
      UpdateRichTextContentParams(
        content: event.content,
        richTextEntity: state.richTextEntity,
      ),
    );
    emit(state.success.copyWith(richTextEntity: newEntity));
  }

  void _onApplyStyle(ApplyStyleEvent event, Emitter<RichTextState> emit) async {
    emit(state.loading);
    final start = event.start;
    final end = event.end;

    if (start == end) {
      emit(state.success);
      return;
    }

    final (failure: failure, value: newEntity) = await applyStyle(
      ApplyStyleParams(
        style: event.style,
        start: start,
        end: end,
        richTextEntity: state.richTextEntity,
      ),
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

  void _onCaretRequested(
    CaretRequested event,
    Emitter<RichTextState> emit,
  ) async {
    emit(state.loading);

    final (failure: failure, value: newCaret) = await getCaret(event.params);

    if (failure != null) {
      emit(state.failure.copyWith(message: () => failure.message));
    } else if (newCaret != null) {
      emit(state.success.copyWith(caretEntity: () => newCaret));
    } else {
      emit(state.failure.copyWith(message: () => 'Something went wrong!!!'));
    }
  }
}
