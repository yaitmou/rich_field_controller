import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rich_field_controller/src/style.dart';

/// An element represents every character in a text field
/// > We don't want to have `TextSpan` per character though.
/// > the [RichParagraph] takes care of merging all characters based
/// > on their respective styles.
///
// ignore: must_be_immutable
class RichElement extends Equatable {
  final String text;
  final int start;
  final int end;
  late RichStyle style;

  RichElement({
    required this.text,
    required this.start,
    int? end,
  }) : end = end ?? start + text.length {
    style = RichStyle(start: start);
  }

  RichElement copyWidth({
    String? text,
    int? start,
  }) =>
      RichElement(
        text: text ?? this.text,
        start: start ?? this.start,
      );

  RichElement merge(RichElement other) {
    RichElement e = RichElement(text: text + other.text, start: start);
    // only elements with the same style can be merged
    // Therefore, we give the merge this element's style!!!
    e.style = style;
    return e;
  }

  TextSpan get span {
    return TextSpan(
      text: text,
      style: style.textStyle,
    );
  }

  @override
  List<Object?> get props => [text, start];

  @override
  String toString() {
    return 'ReditorElement($text, $start, $end,  $style)';
  }
}
