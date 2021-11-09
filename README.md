<p align="center">
<a href="https://pub.dev/packages/rich_field_controller"><img src="https://img.shields.io/pub/v/rich_field_controller.svg" alt="Pub"></a>
<a href="https://github.com/yaitmou/rich_field_controller/actions"><img src="https://github.com/yaitmou/rich_field_controller/workflows/rich_field_controller/badge.svg" alt="build"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>

</p>

A Flutter plugin that turns a TextField into wysiwyg field.

**What does it do:**

<p>
  <img src="https://github.com/yaitmou/rich_field_controller/blob/main/doc/intro.gif?raw=true"
    alt="An animated image of a TextField turned into a rich TextField" />
</p>

> This plugin is still under development. So, Contributors are most welcome ;)

## Usage

This plugin inherits form `TextEditingController`. Therefore, whenever you want to turn a TextField into a wysiwyg, all you have to do is set its controller to be an instance of `RichTextFieldController`.

> The code below is extract from the provided example. Check the examples folder for the complete code.

```dart
import 'package:rich_field_controller/rich_field_controller.dart';

Class Example {
  late final RichFieldController _controller;
  // This is provided for quick integration of common styling.
  // You can use a custom SelectionControls or a MaterialSelectionControls, etc..
  late final RichFieldSelectionControls _selectionControls;

  @override
  void initState() {
    super.initState();
    _controller = RichFieldController(_fieldNode);
    _selectionControls = RichFieldSelectionControls(context, _controller);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: _controller,
        selectionControls: _selectionControls,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}
```

> Remember to dispose of the `RichFieldController` in your widget's `dispose` method

### Updating text style

To update a text style, invoke the `void updateStyle(TextStyle textStyle)` method on the `RichFieldController` instance. In the provided example, this method is extensively used by the `RichfieldToolBarExample` widget to apply styles on the selected text. The `RichFieldController` is completely uncoupled form the toolbar. Therefore, you can crate and style your own toolbar the way you please. Then, invoke the `updateStyle` method in the toolbar actions accordingly.
Here is snipped showing how to **bold** from a `GestureDetector` widget:

```dart
GestureDetector(
  onTap: (){
    controller.updateStyle(const TextStyle(fontWeight: FontWeight.bold));
  }
)
```

For demonstration purposes, we have added the `RichFieldSelectionControls` to cover the basic styling (bold, italic, underline, strickThrough). Under the hood, it extends the `MaterialTextSelectionControls` and uses the `updateSelectedTextStyle(TextStyle textStyle)` to apply styles. For your Flutter app, you may want to implement your own `TextSelectionControls` to provide the styles you need.

### FocusNode

If you provide a `focusNode` argument to the `RichFieldController`, the corresponding `TextField` widget will keep focus while being styled. That is particularly useful when you use a toolbar.
