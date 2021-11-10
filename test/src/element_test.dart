import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_field_controller/src/element.dart';

void main() {
  group('RichElement', () {
    late RichElement element;
    setUp(() {
      element = RichElement(text: 'a', start: 0);
    });
    test(
        'Merged element should have both text concatenated and the receiver style',
        () {
      // ARRANGE
      var elementA = RichElement(text: 'a', start: 0);
      var elementB = RichElement(text: 'b', start: 1);
      var expectedElement = RichElement(text: 'ab', start: 0);
      // ACT
      final mergedElement = elementA.merge(elementB);

      // ASSERT
      expect(mergedElement, expectedElement);
    });
    test(
        'Given an element with text `a` and start 0, the initial TextSpan should have the same text and a null TextStyle',
        () {
      // ARRANGE
      const expectedSpan = TextSpan(text: 'a', style: null);
      // ACT
      final span = element.span;

      // ASSERT
      expect(span, expectedSpan);
    });
  });
}
