<p align="center">
<a href="https://pub.dev/packages/rich_field_controller"><img src="https://img.shields.io/pub/v/rich_field_controller.svg" alt="Pub"></a>
<a href="https://github.com/yaitmou/rich_field_controller/actions"><img src="https://img.shields.io/github/workflow/status/yaitmou/rich_field_controller/rich_field_controller" alt="build"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>

</p>

A Flutter plugin that turns a TextField into a WYSIWYG field.
The philosophy here is to keep using the built-in TextField and update its corresponding controller
instead of creating a hole new widget.

> **Our philosophy**
> In simplicity resides efficiency

**What does it do:**

<p>
  <img src="https://github.com/yaitmou/rich_field_controller/blob/main/doc/intro.gif?raw=true"
    alt="An animated image of a TextField turned into a rich TextField" />
</p>

> This plugin is still under development. So, Contributors are most welcome to join :wink:

## Usage

This plugin inherits form `TextEditingController`. Therefore, whenever you want to turn a TextField
into a WYSIWYG, all you have to do is to set its controller to be an instance of
`RichTextFieldController`.

> **Hint**
> The code below is extracted from the provided example. Check the examples folder for the complete
> code.

> :warning:
> We have removed the RichSelectionControls. For now we have commented the corresponding file's code
> and we are moving to `contextMenuBuilder` as recommended
> [here](https://docs.flutter.dev/release/breaking-changes/context-menus#textselectioncontrols-cancut-and-other-button-booleans).
> A new version will be published soon with these updated. Hit me up if you are interested in
> implementing this feature :wink:

```dart
import 'package:rich_field_controller/rich_field_controller.dart';

Class Example {
  late final RichFieldController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichFieldController(_fieldNode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: _controller,
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

### Updating text style

To update a text style, invoke the `void updateStyle(TextStyle textStyle)` method on the
`RichFieldController` instance. In the provided example, this method is extensively used by the
`RichfieldToolBarExample` widget. The `RichFieldController` is completely uncoupled form the
toolbar. Therefore, you can crate and style your own toolbar the way you please. Then, invoke the
`updateStyle` method from the toolbar's actions accordingly. Here is snipped showing how to **bold**
a selected text from a `GestureDetector` widget:

```dart
GestureDetector(
  onTap: (){
    controller.updateStyle(const TextStyle(fontWeight: FontWeight.bold));
  }
)
```

### FocusNode

If you provide a `focusNode` argument to the `RichFieldController`, the corresponding `TextField`
widget will keep focus while being styled. That is particularly handy when you use a toolbar.
