import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Holds the Reditor style rules and their md equivalence
// ignore: must_be_immutable
class RichStyle extends Equatable {
  final int start;
  final int end;

  Set<TextStyle> styles;

  RichStyle({
    required this.start,
    this.styles = const {},
  }) : end = start + 1;

  get length => end - start;

  // Merge all styles into a single style to be used with the text span
  // Also, we check if we have any decorations to be combined!
  get textStyle {
    if (styles.isEmpty) {
      return null;
    }
    return styles.reduce(
      (value, element) => element.merge(value).copyWith(
            decoration: TextDecoration.combine([
              value.decoration ?? TextDecoration.none,
              element.decoration ?? TextDecoration.none,
            ]),
          ),
    );
  }

  // For the time being, we need to have toggle, add, and remove text style
  // as separate methods. It's attempting though to merge them into a single
  // one. But that won't result in any performance improvement. So give it up
  // Remember Donald knuth's saying ;)
  void toggleTextStyle(TextStyle textStyle) {
    final backgroundFound = styles.where(
      (s) {
        if (s.background != null && textStyle.background != null) {
          return s.background!.color == textStyle.background!.color;
        }
        return false;
      },
    ).toList();
    if (backgroundFound.isNotEmpty) {
      styles = styles
          .where((s) => s.background!.color != textStyle.background!.color)
          .toSet();
    } else if (styles.contains(textStyle)) {
      styles = styles.where((s) => s != textStyle).toSet();
    } else {
      styles = {...styles, textStyle};
    }
    backgroundFound.clear();
  }

  // Read above before refactoring!
  void addTextStyle(TextStyle textStyle) {
    if (!styles.contains(textStyle)) {
      styles = {...styles, textStyle};
    }
  }

  // Read above before refactoring!
  void removeStyle(TextStyle textStyle) {
    if (styles.contains(textStyle)) {
      styles = styles.where((s) => s != textStyle).toSet();
    }
  }

  RichStyle copyWith({
    int? start,
    int? end,
    Set<TextStyle>? styles,
  }) =>
      RichStyle(
        start: start ?? this.start,
        styles: styles ?? this.styles,
      );

  @override
  List<Object?> get props => [start];

  @override
  String toString() {
    return 'ReditorStyle($start, $end, $styles)';
  }
}
