import 'package:file_flow/models/document.dart';
import 'package:flutter/material.dart';

import '../../translations.dart';


class CategoryDropdownField extends StatefulWidget {
  final DocumentCategory? initialValue;
  final void Function(DocumentCategory)? onChange;

  const CategoryDropdownField({super.key, this.initialValue, this.onChange});

  @override
  State<CategoryDropdownField> createState() => _CategoryDropdownFieldState();
}

class _CategoryDropdownFieldState extends State<CategoryDropdownField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: DropdownMenu<DocumentCategory>(
        width: 300,
        initialSelection: widget.initialValue,
        onSelected: (c) {
          if (c != null) widget.onChange?.call(c);
        },
        dropdownMenuEntries: DocumentCategory.list()
            .map((value) =>
            DropdownMenuEntry<DocumentCategory>(
              value: value,
              label: translateCategory[value.jsonValue]!,
            ))
            .toList(),
      ),
    );
  }
}
