// lib/src/domain/entities/caret_entity.dart

import 'package:equatable/equatable.dart';

class CaretEntity extends Equatable {
  final double xPosition;
  final double yPosition;
  final int lineNumber;
  final bool isAtFirstLine;
  final bool isAtLastLine;
  final int offset;
  final double width;
  final double height;

  const CaretEntity({
    required this.xPosition,
    required this.yPosition,
    required this.lineNumber,
    required this.isAtFirstLine,
    required this.isAtLastLine,
    required this.offset,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [
        xPosition,
        yPosition,
        lineNumber,
        isAtFirstLine,
        isAtLastLine,
        offset,
        width,
        height,
      ];
}
