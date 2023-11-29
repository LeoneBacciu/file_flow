import 'package:flutter/material.dart';

import '../../../models/document.dart';
import 'search_context.dart';
import 'search_date_range.dart';
import 'search_notifier.dart';

class SearchDialog extends StatelessWidget {
  final TagSet tags;

  const SearchDialog({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    final dropdownWidth = MediaQuery.sizeOf(context).width - 128;
    final notifier = SearchContext.of(context);
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: const Text('Filtra e Ordina'),
      content: SizedBox(
        // Consistent Width
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!notifier.lockedCategory)
              _pad(
                DropdownMenu<DocumentCategory?>(
                  width: dropdownWidth,
                  label: const Text('Categoria'),
                  initialSelection: notifier.category,
                  onSelected: (c) => notifier.category = c,
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: null, label: 'Tutte'),
                    for (final c in DocumentCategory.list())
                      DropdownMenuEntry(value: c, label: c.displayName),
                  ],
                ),
              ),
            _pad(
              DropdownMenu<bool>(
                width: dropdownWidth,
                label: const Text('Ordine'),
                initialSelection: notifier.descending,
                onSelected: (d) => d != null ? notifier.descending = d : null,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: true, label: 'Discendente'),
                  DropdownMenuEntry(value: false, label: 'Ascendente'),
                ],
              ),
            ),
            _pad(
              DropdownMenu<SearchSortPolicy>(
                width: dropdownWidth,
                label: const Text('Ordina per'),
                initialSelection: notifier.sortPolicy,
                onSelected: (p) => p != null ? notifier.sortPolicy = p : null,
                dropdownMenuEntries: [
                  for (final p
                      in SearchSortPolicy.listForCategory(notifier.category))
                    DropdownMenuEntry(value: p, label: p.displayName),
                ],
              ),
            ),
            if (notifier.tags.isNotEmpty) _pad(const Text('Tags')),
            if (notifier.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: tags
                    .map(
                      (t) => InputChip(
                        onSelected: (add) => notifier.toggleTag(t, add),
                        selected: notifier.tags.contains(t),
                        label: Text(t),
                      ),
                    )
                    .toList(),
              ),
            if (notifier.category?.parsing ?? false)
              _pad(const SearchDateRange()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Invia'),
        ),
      ],
    );
  }

  Widget _pad(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: child,
      );
}
