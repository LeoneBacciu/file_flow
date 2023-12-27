import 'package:flutter/material.dart';

import '../../../models/document.dart';
import '../../colors.dart';
import 'search_context.dart';
import 'search_dialog.dart';

class DocumentSearchBar extends StatefulWidget {
  final TagSet tags;

  const DocumentSearchBar({super.key, required this.tags});

  @override
  State<DocumentSearchBar> createState() => _DocumentSearchBarState();
}

class _DocumentSearchBarState extends State<DocumentSearchBar> {
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
                onChanged: (q) => SearchContext.of(context).query = q,
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                leading: const Icon(Icons.search),
                trailing: [
                  IconButton(
                    onPressed: () => _buildSearchDialog(context),
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).viewPadding.top,
              color: lighten(seedColor, 1 / 15),
            ),
          ),
        ],
      ),
    );
  }

  void _buildSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SearchContext(
        notifier: SearchContext.of(context),
        child: SearchDialog(tags: widget.tags),
      ),
    );
  }
}
