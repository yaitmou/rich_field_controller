A Flutter plugin that turns the well-known TextField into a rich text editing field.

<p>
  <img src="https://github.com/yaitmou/rich_field_controller/blob/main/doc/intro.gif?raw=true"
    alt="An animated image of a TextField turned into a rich TextField" />
  
</p>

> This plugin is still under development. It should work as-is, however, new features may be added in a near future. Contributors are most welcome ;)

## Usage

This plugin inherits form TextEditingController. Therefore, whenever you want to turn a TextField into a rich TextField, all you have to do is set its controller to be an instance of RichTextFieldController.

> The code below is extract from the provided example. Check the examples folder for the complete code.

```dart
import 'package:rich_field_controller/rich_field_controller.dart';

Class Example {
  // A FocusNode is required to keep track of the selected text
  // That is particularly true when using a toolbar
  late final FocusNode _fieldNode;
  late final RichFieldController _controller;
  // This is provided for quick integration of common styling.
  // You can use a custom SelectionControls or a MaterialSelectionControls, etc..
  late final RichFieldSelectionControls _selectionControls;

  @override
  void initState() {
    super.initState();
    _fieldNode = FocusNode();
    _controller = RichFieldController(_fieldNode);
    _selectionControls = RichFieldSelectionControls(context, _controller);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: _controller,
        focusNode: _fieldNode,
        selectionControls: _selectionControls,
      ),
    );
  }

}
```

> Remember to dispose both the `FocusNode` and the `RichFieldController` in your widget's dispose function
>
> ```dart
> //...
> @override
>   void dispose() {
>     _controller.dispose();
>     _fieldNode.dispose();
>     super.dispose();
>   }
> //...
>
> ```

### FocusNode()

A `FocusNode` is required by the `RichFieldController` so that it can keep track of what text is being edited.

### Updating a style programmatically

As long as you provide a `RichFieldSelectionControls`, you can update the text style from anywhere in your code by calling the `updateActiveElementStyle(TextStyle textStyle)` function.

```dart
controller.paragraph.updateActiveElementStyle(newStyle);
```

We have added the `RichFieldSelectionControls` to cover the basic styling (bold, italic, underline, strickThrough). Under the hood, it uses the `updateActiveElementStyle(TextStyle textStyle)` to apply styles.
