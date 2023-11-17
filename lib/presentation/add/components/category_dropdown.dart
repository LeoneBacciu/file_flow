import 'package:file_flow/core/translations.dart';
import 'package:flutter/material.dart';

import '../../../models/document.dart';

class CategoryDropdown extends StatelessWidget {
  final DocumentCategory category;
  final void Function(DocumentCategory) onChange;

  const CategoryDropdown(
      {super.key, required this.category, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: DropdownMenu<DocumentCategory>(
        width: 300,
        initialSelection: category,
        onSelected: (c) => onChange(c!),
        dropdownMenuEntries: DocumentCategory.list()
            .map((value) => DropdownMenuEntry<DocumentCategory>(
                  value: value,
                  label: translateCategory[value.jsonValue]!,
                ))
            .toList(),
      ),
    );
  }
}
