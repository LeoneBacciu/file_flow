import 'package:flutter/material.dart';

class FilenameTextField extends StatefulWidget {
  final String? initialValue;
  final void Function(String)? onChange;

  const FilenameTextField({super.key, this.initialValue, this.onChange});

  @override
  State<FilenameTextField> createState() => _FilenameTextFieldState();
}

class _FilenameTextFieldState extends State<FilenameTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        initialValue: widget.initialValue,
        onChanged: (v) => widget.onChange?.call(v),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Nome Documento',
        ),
      ),
    );
  }
}
