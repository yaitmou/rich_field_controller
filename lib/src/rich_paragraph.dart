import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'dart:math' as math;

import 'package:rich_field_controller/src/element.dart';
import 'package:rich_field_controller/src/style.dart';

/// The core functionalities of the [RichFieldController] are handled here.
///
/// The [RichParagraph] splits the content of a `TextField` into single characters.
/// Then it create a
class RichParagraph {
  final FocusNode? node;
  RichParagraph({this.node});

  String _text = '';

  Set<RichElement> _elements = {};
  get elements => _elements;

  final Set<RichElement> _curatedElements = {};

  List<RichElement> _selectedElements = [];
  get selectedElements => _selectedElements;

  Set<RichStyle> _styles = {};
  get styles => _styles;

  List<InlineSpan>? _spans;

  int? _cursorPosition;
  get cursorPosition => _cursorPosition;

  TextSelection? _selection;
  get selection => _selection;

  /// Sets the [_elements] to be styled
  void _setActiveElement() {
    _selectedElements.clear();
    if (_selection!.isCollapsed) {
      // scan backward until we hit a space character
      for (var i = _cursorPosition! - 1; i >= 0 && i < _elements.length; i--) {
        final e = _elements.elementAt(i);
        if (e.text == ' ') {
          break;
        }
        if (e.start == i) {
          _selectedElements.add(e);
        }
      }
      // scan forward until we hit a space character
      for (var i = _cursorPosition!; i < _elements.length; i++) {
        final e = _elements.elementAt(i);
        if (e.text == ' ') {
          break;
        }
        if (e.start == i) {
          _selectedElements.add(e);
        }
      }
    } else {
      // Account for when we select by dragging from left to right and vice vers ca
      var selectionStart = math.min(_selection!.baseOffset, _selection!.extentOffset);
      var selectionEnd = math.max(_selection!.baseOffset, _selection!.extentOffset);
      _selectedElements = _elements.where((e) => e.start >= selectionStart && e.end <= selectionEnd).toList();
    }
  }

  /// Add a new element to the list of elements buffer
  /// This is called every time text is update!!
  ///
  /// Each element will be linked to it's corresponding style entry in the
  /// [_styles] buffer. This is what keeps the element styled in the textField!
  /// Basically the `_styles` buffer acts like a mask that is layed on top the
  /// textField's text.
  ///
  void _addElement(String text, int start) {
    var el = RichElement(text: text, start: start);
    // look for a style that matches the element's position
    final s = _styles.singleWhereOrNull((s) => s.start == el.start);
    if (el.text != '' && el.start >= 0) {
      if (s != null) {
        el.style = s;
      }
      _elements.add(el);
    }
  }

  /// Since the `_styles` buffer acts like a mask on top of the text, we need
  /// to update its entries to keep them in sync with the underlying text.
  void _updateStylesRange(String newText) {
    /// Used to determine whether we are adding or deleting text
    final _delta = newText.length - _text.length;

    // Cleaning styles buffer by removing range-less styles
    _styles.removeWhere((s) {
      return s.start >= s.end;
    });

    // Cleaning styles buffer by removing floating styles.
    // This are styles that are not linked to any element
    var floatingStyles = [];
    for (var s in _styles) {
      var styledElement = _elements.singleWhereOrNull((e) => s.start == e.start && s.end == e.end);
      if (styledElement == null) {
        floatingStyles.add(s);
      }
    }
    _styles.removeWhere((s) => floatingStyles.contains(s));

    // Correct style ranges
    _styles = _styles.map((s) {
      // We are updating text before [s]
      if (s.start >= _cursorPosition!) {
        // we need to shift the style to keep it in sync with its element
        return s.copyWith(start: s.start + _delta);
      }
      return s;
    }).toSet();
  }

  void updateSelection(TextSelection newSelection) {
    // Make sure we have something selected
    if (newSelection.isValid) {
      _selection = newSelection;
      _cursorPosition = _selection!.baseOffset;
      _setActiveElement();
    }
  }

  /// Get newly added text and update the [_element]s buffer
  ///
  /// This is called on every text change of the textField
  void updateText(String newText) {
    _updateStylesRange(newText);
    _elements.clear();
    int elementStart = -1;

    newText.splitMapJoin(
      '',
      onNonMatch: (s) {
        _addElement(s, elementStart);
        elementStart++;
        return s;
      },
    );

    _text = newText;

    if (_text.isEmpty) {
      _styles.clear();
    }
  }

  /// Update active element [style]s list
  ///
  /// This is the main method that is called from toolbar and context menu actions
  void updateSelectedTextStyle(TextStyle style) {
    if (node != null) {
      node!.requestFocus();
    }
    // Make sure we have something to style!
    if (_selectedElements.isNotEmpty) {
      // If we have selected more than one element, we need to sync all
      // their respective styles in regards to this [newStyle]
      var _isDiscrepancy = false;
      final elementWithStyle = _selectedElements.firstWhereOrNull((e) => e.style.styles.contains(style));
      final elementWithoutStyle = _selectedElements.firstWhereOrNull((e) => !e.style.styles.contains(style));
      _isDiscrepancy = elementWithStyle != null && elementWithoutStyle != null;
      for (var e in _selectedElements) {
        final newStyle = RichStyle(start: e.start);
        if (_styles.contains(newStyle)) {
          // If the style is in the [_styles] buffer that means it's already
          // linked to an element. Thus, there is no need to link it here again
          _styles = _styles.map((s) {
            if (s == newStyle) {
              // We toggle the style only if there are no discrepancies
              if (!_isDiscrepancy) {
                s.toggleTextStyle(style);
              } else {
                s.addTextStyle(style);
              }
            }
            return s;
          }).toSet();
        } else {
          // If the style is not in the [_styles] buffer that means we need
          // to add it. Hence, we need to link it to it's corresponding element
          newStyle.toggleTextStyle(style);
          _styles.add(newStyle);
          _elements = _elements.map((element) {
            if (element == e) {
              element.style = newStyle;
            }
            return element;
          }).toSet();
        }
      }
    }
  }

  /// Build a list of InlineSpans
  /// Only needed spans are returned.
  List<InlineSpan> buildTextSpans() {
    _elements.removeWhere((e) => e.start == e.end);

    _spans = [];
    _curatedElements.clear();
    RichElement? mergedElement;

    for (var i = 0; i < _elements.length; i++) {
      // merge elements
      final currentElement = _elements.elementAt(i);
      final nextElement = (i < _elements.length - 1) ? _elements.elementAt(i + 1) : null;
      mergedElement ??= currentElement;
      if (nextElement != null) {
        if (currentElement.style.textStyle == nextElement.style.textStyle) {
          mergedElement = mergedElement.merge(nextElement);
        } else {
          _curatedElements.add(mergedElement);
          mergedElement = null;
        }
      } else {
        _curatedElements.add(mergedElement);
      }
    }

    for (var e in _curatedElements) {
      _spans!.add(e.span);
    }

    return _spans!;
  }
}
