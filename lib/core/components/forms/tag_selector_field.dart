import 'package:flutter/material.dart';

class TagSelectorField extends StatefulWidget {
  final Set<String>? initialState;
  final void Function(Set<String>)? onChange;

  const TagSelectorField({super.key, this.initialState, this.onChange});

  @override
  State<TagSelectorField> createState() => _TagSelectorFieldState();
}

class _TagSelectorFieldState extends State<TagSelectorField> {
  final candidates = {'Luce', 'Gas', 'Acqua'};
  late final tags = widget.initialState ?? {};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        children: candidates
            .map(
              (c) => InputChip(
                selected: tags.contains(c),
                label: Text(c),
                onSelected: (b) => setState(() {
                  if (b) {
                    tags.add(c);
                  } else {
                    tags.remove(c);
                  }
                  widget.onChange?.call(tags);
                }),
              ),
            )
            .toList(),
      ),
    );
  }
}
