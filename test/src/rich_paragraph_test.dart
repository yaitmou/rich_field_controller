import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_field_controller/src/rich_paragraph.dart';
import 'package:rich_field_controller/src/element.dart';
import 'package:rich_field_controller/src/style.dart';

void main() {
  group('RichParagraph', () {
    late RichParagraph paragraph;
    late TextSelection selection;
    setUp(() {
      paragraph = RichParagraph();
      paragraph.updateText('Rich text field test content');
      selection = const TextSelection(baseOffset: 5, extentOffset: 9);
      paragraph.updateSelection(selection);
    });
    group('Text editing', () {
      test('Text should be updated with the new text', () {
        final expectedElements = <RichElement>{
          RichElement(text: 't', start: 0),
          RichElement(text: 'e', start: 1),
          RichElement(text: 's', start: 2),
          RichElement(text: 't', start: 3),
        };
        paragraph.updateText('test');
        expect(paragraph.elements, expectedElements);
      });
    });
    group('Elements styling', () {
      test('Given a selection, when text style is applied, then the style set should match with the selection range', () {
        var expectedStyles = {
          RichStyle(start: 5, styles: {const TextStyle(fontWeight: FontWeight.bold)}),
          RichStyle(start: 6, styles: {const TextStyle(fontWeight: FontWeight.bold)}),
          RichStyle(start: 7, styles: {const TextStyle(fontWeight: FontWeight.bold)}),
          RichStyle(start: 8, styles: {const TextStyle(fontWeight: FontWeight.bold)}),
        };
        paragraph.updateSelection(const TextSelection(baseOffset: 5, extentOffset: 5));
        paragraph.updateSelectedTextStyle(const TextStyle(fontWeight: FontWeight.bold));
        expect(paragraph.styles, expectedStyles);
      });
      test('Given a selection, when selected element is already styled, then the style should be removed', () {
        var expectedStyles = {
          RichStyle(start: 5, styles: {}),
          RichStyle(start: 6, styles: {const TextStyle(fontWeight: FontWeight.bold)}),
          RichStyle(start: 7, styles: {const TextStyle(fontWeight: FontWeight.bold)}),
          RichStyle(start: 8, styles: {const TextStyle(fontWeight: FontWeight.bold)}),
        };

        paragraph.updateSelection(const TextSelection(baseOffset: 5, extentOffset: 5));
        paragraph.updateSelectedTextStyle(const TextStyle(fontWeight: FontWeight.bold));
        paragraph.updateSelection(const TextSelection(baseOffset: 5, extentOffset: 6));
        paragraph.updateSelectedTextStyle(const TextStyle(fontWeight: FontWeight.bold));

        expect(paragraph.styles, expectedStyles);
      });

      test('When no styles are applied, only one span should be built', () {
        const expectedSpans = <InlineSpan>[
          TextSpan(text: 'Rich text field test content'),
        ];

        final spans = paragraph.buildTextSpans();

        expect(spans, expectedSpans);
      });
      test('When styles are applied, built spans should be grouped by style', () {
        const expectedSpans = <InlineSpan>[
          TextSpan(text: 'Rich', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' text field'),
          TextSpan(text: ' test content', style: TextStyle(fontWeight: FontWeight.bold)),
        ];

        paragraph.updateSelection(const TextSelection(baseOffset: 0, extentOffset: 4));
        paragraph.updateSelectedTextStyle(const TextStyle(fontWeight: FontWeight.bold));
        paragraph.updateSelection(const TextSelection(baseOffset: 15, extentOffset: 28));
        paragraph.updateSelectedTextStyle(const TextStyle(fontWeight: FontWeight.bold));
        final spans = paragraph.buildTextSpans();

        expect(spans, expectedSpans);
      });
    });
    group('Update selection', () {
      test('Cursor position should be at the base offset', () {
        final expectedCursorPosition = selection.baseOffset;
        expect(paragraph.cursorPosition, expectedCursorPosition);
      });

      test('Selected elements should be within the selection range', () {
        final expectedSelectedElements = {
          RichElement(text: 't', start: 5),
          RichElement(text: 'e', start: 6),
          RichElement(text: 'x', start: 7),
          RichElement(text: 't', start: 8),
        };
        expect(paragraph.selectedElements, expectedSelectedElements);
      });
      test('With collapsed selection, selected elements should hold a word that contains the cursor position', () {
        final expectedSelectedElements = {
          RichElement(text: 't', start: 5),
          RichElement(text: 'e', start: 6),
          RichElement(text: 'x', start: 7),
          RichElement(text: 't', start: 8),
        };
        paragraph.updateSelection(const TextSelection(baseOffset: 5, extentOffset: 5));
        expect(paragraph.selectedElements, expectedSelectedElements);
        paragraph.updateSelection(const TextSelection(baseOffset: 6, extentOffset: 6));
        expect(paragraph.selectedElements, expectedSelectedElements);
        paragraph.updateSelection(const TextSelection(baseOffset: 8, extentOffset: 8));
        expect(paragraph.selectedElements, expectedSelectedElements);
      });
    });
  });
}
