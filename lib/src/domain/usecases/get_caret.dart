// Copyright (c) 2024 Younss Ait Mou. All rights reserved.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:rich_field_controller/src/core/failure/failure.dart';
import 'package:rich_field_controller/src/core/usecase/usecase.dart';
import 'package:rich_field_controller/src/domain/entities/caret.dart';

class CaretParams extends Equatable {
  final TextPainter painter;
  final TextSelection selection;
  final double tolerance;

  const CaretParams({
    required this.painter,
    required this.selection,
    this.tolerance = 0.5,
  });
  @override
  List<Object?> get props => [painter, selection, tolerance];
}

class GetCaret implements UseCase<CaretEntity, CaretParams> {
  TextPainter? painter;
  @override
  call(params) {
    final painter = params.painter;
    final selection = params.selection;
    final tolerance = params.tolerance;

    final lines = painter.computeLineMetrics();

    bool isAtFirstLine = false;
    bool isAtLastLine = false;
    int lineNumber = 0;

    if (lines.isEmpty) {
      isAtFirstLine = true;
      isAtLastLine = true;
    } else {
      final caretOffset = painter.getOffsetForCaret(
        TextPosition(offset: selection.baseOffset),
        Rect.zero,
      );
      isAtFirstLine = caretOffset.dy.abs() < tolerance;
      final lastMetric = lines.last;
      isAtLastLine = caretOffset.dy + tolerance > lastMetric.height * lastMetric.lineNumber;

      // Calculate line number
      for (var i = 0; i < lines.length; i++) {
        if (caretOffset.dy <= lines[i].height * (i + 1)) {
          lineNumber = i;
          break;
        }
      }

      return Future.value((
        failure: null,
        value: CaretEntity(
          xPosition: caretOffset.dx,
          yPosition: caretOffset.dy,
          lineNumber: lineNumber,
          isAtFirstLine: isAtFirstLine,
          isAtLastLine: isAtLastLine,
          offset: selection.baseOffset,
          width: painter.width,
          height: painter.height,
        ),
      ));
    }
    return Future.value((
      failure: const Failure('Caret Failure: lines empty'),
      value: null,
    ));
  }
}
