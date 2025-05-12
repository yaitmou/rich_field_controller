import 'package:get_it/get_it.dart';
import 'package:rich_field_controller/src/domain/usecases/apply_style.dart';
import 'package:rich_field_controller/src/domain/usecases/get_caret.dart';
import 'package:rich_field_controller/src/domain/usecases/update_text.dart';
import 'package:rich_field_controller/src/presentation/bloc/rich_text_bloc.dart';

final sl = GetIt.instance;

Future<void> initRichTextEditingController() async {
  //  use cases
  sl.registerLazySingleton(() => GetCaret());
  sl.registerLazySingleton(() => ApplyStyle());
  sl.registerLazySingleton(() => UpdateRichTextContent());

  // bloc
  sl.registerLazySingleton(
    () => RichTextBloc(
      getCaret: sl(),
      applyStyle: sl(),
      updateRichTextContent: sl(),
    ),
  );
}
