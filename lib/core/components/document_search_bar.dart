import 'package:file_flow/models/document.dart';
import 'package:file_flow/models/search_query.dart';
import 'package:flutter/material.dart';

class DocumentSearchBar extends StatefulWidget {
  final void Function(SearchQuery) onSearch;
  final DocumentCategory? category;

  const DocumentSearchBar({super.key, required this.onSearch, this.category});

  @override
  State<DocumentSearchBar> createState() => _DocumentSearchBarState();
}

class _DocumentSearchBarState extends State<DocumentSearchBar> {
  late SearchQuery _query = SearchQuery('', widget.category);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      pinned: true,
      collapsedHeight: kToolbarHeight + 32,
      expandedHeight: kToolbarHeight + 32,
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
        child: SearchBar(
          onChanged: (text) =>
              widget.onSearch(_query = SearchQuery(text, widget.category)),
          padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Icons.search),
          trailing: const [Icon(Icons.tune)],
        ),
      ),
    );
  }
}
