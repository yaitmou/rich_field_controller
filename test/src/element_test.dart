import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_field_controller/src/element.dart';

void main() {
  group('RichElement', () {
    late RichElement element;
    setUp(() {
      element = RichElement(text: 'a', start: 0);
    });
    test('Given an element with text `a` and start 0, the initial TextSpan should have the same text and a null TextStyle', () {
      // ARRANGE
      const expectedSpan = TextSpan(text: 'a', style: null);
      // ACT
      final span = element.span;

      // ASSERT
      expect(span, expectedSpan);
    });
  });
}
