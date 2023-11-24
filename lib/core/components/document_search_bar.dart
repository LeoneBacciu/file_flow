import 'package:flutter/material.dart';

import '../../models/document.dart';
import '../../models/search_query.dart';

class DocumentSearchBar extends StatefulWidget {
  final void Function(SearchQuery) onSearch;
  final DocumentCategory? category;

  const DocumentSearchBar({super.key, required this.onSearch, this.category});

  @override
  State<DocumentSearchBar> createState() => _DocumentSearchBarState();
}

class _DocumentSearchBarState extends State<DocumentSearchBar> {
  // ignore: unused_field
  late SearchQuery _query = SearchQuery('', widget.category);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      pinned: true,
      collapsedHeight: 76,
      expandedHeight: 76,
      flexibleSpace: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: SearchBar(
                onChanged: (text) => widget
                    .onSearch(_query = SearchQuery(text, widget.category)),
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                leading: const Icon(Icons.search),
                trailing: const [Icon(Icons.tune)],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).viewPadding.top,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
