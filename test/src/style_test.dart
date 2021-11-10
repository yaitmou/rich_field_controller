import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_field_controller/src/style.dart';

void main() {
  group('RichStyle', () {
    late RichStyle style;
    setUp(() {
      style = RichStyle(start: 0, styles: {
        const TextStyle(fontWeight: FontWeight.bold),
        const TextStyle(fontSize: 24),
      });
    });
    test('TextStyle should contain all of the merged styles', () {
      const expectedTextStyle = TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          decoration: TextDecoration.none);
      final textStyle = style.textStyle;
      expect(textStyle, expectedTextStyle);
    });
    test('TextStyle should be toggled', () {
      const expectedTextStyle = TextStyle(fontSize: 24);
      style.toggleTextStyle(const TextStyle(fontWeight: FontWeight.bold));
      final textStyle = style.textStyle;
      expect(textStyle, expectedTextStyle);
    });
    test('Add a TextStyle', () {
      const expectedTextStyle = TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.none);
      style.addTextStyle(const TextStyle(fontStyle: FontStyle.italic));
      final textStyle = style.textStyle;
      expect(textStyle, expectedTextStyle);
    });
    test('Remove a TextStyle', () {
      const expectedTextStyle = TextStyle(fontSize: 24);
      style.removeStyle(const TextStyle(fontWeight: FontWeight.bold));
      final textStyle = style.textStyle;
      expect(textStyle, expectedTextStyle);
    });
  });
}
