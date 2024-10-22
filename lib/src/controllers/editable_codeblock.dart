import 'package:flutter/material.dart';

class EditableCodeBlock extends StatefulWidget {
  final String initialCode;
  final Function(String) onChanged;
  final TextStyle textStyle;

  const EditableCodeBlock({
    super.key,
    required this.initialCode,
    required this.onChanged,
    required this.textStyle,
  });

  @override
  State<EditableCodeBlock> createState() => _EditableCodeBlockState();
}

class _EditableCodeBlockState extends State<EditableCodeBlock> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: TextField(
          autofocus: true,
          controller: _controller,
          style: widget.textStyle.copyWith(fontFamily: 'monospace'),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
            border: InputBorder.none,
          ),
          maxLines: null,
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
