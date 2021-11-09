import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_field_controller/src/rich_paragraph.dart';
import 'package:rich_field_controller/src/element.dart';

void main() {
  group('RichParagraph', () {
    late RichParagraph paragraph;
    late TextSelection selection;
    setUp(() {
      paragraph = RichParagraph(FocusNode());
      paragraph.updateText('Rich text field test content');
      selection = const TextSelection(baseOffset: 5, extentOffset: 9);
      paragraph.updateSelection(selection);
    });
    group('Elements editing', () {
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
        paragraph.updateSelection(const TextSelection(baseOffset: 6, extentOffset: 6));
        expect(paragraph.selectedElements, expectedSelectedElements);
      });
    });
  });
}
