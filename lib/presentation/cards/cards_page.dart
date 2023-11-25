import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/components/common.dart';
import '../../core/components/search/document_search_bar.dart';
import '../../core/components/search/search_context.dart';
import '../../core/components/search/search_notifier.dart';
import '../../core/components/stateful_indexed_page.dart';
import '../../models/document.dart';
import '../../state/sync/sync_cubit.dart';
import 'components/cards_card.dart';

class CardsPage extends StatefulIndexedPage {
  const CardsPage({
    super.key,
    required super.onRouteChange,
    required super.onNewDocument,
  });

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final notifier = SearchNotifier(DocumentCategory.card);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SearchContext(
          notifier: notifier,
          child: BlocBuilder<SyncCubit, SyncState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  DocumentSearchBar(
                    tags: (state is SyncLoaded)
                        ? state.documents
                            .where((d) => d.category == DocumentCategory.card)
                            .toList()
                            .extractTags()
                        : {},
                  ),
                  SliverList.list(
                    children: (state is SyncLoaded)
                        ? state.documents
                            .unfrozen()
                            .where(SearchContext.of(context).filter)
                            .sorted(SearchContext.of(context).order)
                            .map((d) => CardsCard(document: d))
                            .toList()
                        : [],
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 1000)),
                  //TODO: Remove
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: commonFloatingActionButton(
        context,
        DocumentCategory.card,
            () => widget.onNewDocument!(DocumentCategory.card),
      ),
      bottomNavigationBar: commonNavigationBar(
        context,
        NavigationRoute.cards,
        widget.onRouteChange,
      ),
    );
  }
}
