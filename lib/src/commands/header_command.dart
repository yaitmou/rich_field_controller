// lib/src/commands/header_command.dart
import 'package:rich_field_controller/src/domain/entities/rich_text_style.dart';

class HeaderCommand {
  final int start;
  final int end;
  final int level;
  final bool tagsVisible;

  const HeaderCommand({
    required this.start,
    required this.end,
    required this.level,
    this.tagsVisible = false,
  });

  HeaderCommand copyWith({
    int? start,
    int? end,
    int? level,
    bool? tagsVisible,
  }) {
    return HeaderCommand(
      start: start ?? this.start,
      end: end ?? this.end,
      level: level ?? this.level,
      tagsVisible: tagsVisible ?? this.tagsVisible,
    );
  }

  RichTextStyle get style => RichTextStyle(headerLevel: level);

  String get prefix => '${'#' * level} ';
}
