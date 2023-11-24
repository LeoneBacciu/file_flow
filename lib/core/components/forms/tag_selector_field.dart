import 'package:flutter/material.dart';

import '../../../models/document.dart';
import 'tag_dialog.dart';

class TagSelectorField extends StatefulWidget {
  final TagSet defaultTags;
  final TagSet? initialValue;
  final void Function(TagSet)? onChange;

  const TagSelectorField({
    super.key,
    this.defaultTags = const {},
    this.initialValue,
    this.onChange,
  });

  @override
  State<TagSelectorField> createState() => _TagSelectorFieldState();
}

class _TagSelectorFieldState extends State<TagSelectorField> {
  final extraTags = <String>{};
  late final tags = widget.initialValue ?? {};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        children: [
          for (final c in widget.defaultTags.union(extraTags))
            InputChip(
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
          RawChip(
            label: const Text('+'),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 2,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            ),
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (context) => const TagDialog(),
              ).then((t) {
                if (t != null) {
                  setState(() {
                    extraTags.add(t);
                    tags.add(t);
                  });
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
