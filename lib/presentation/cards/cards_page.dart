import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/components/common.dart';
import '../../core/components/document_search_bar.dart';
import '../../core/components/search_query_state.dart';
import '../../core/components/stateful_indexed_page.dart';
import '../../models/document.dart';
import '../../models/search_query.dart';
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

class _CardsPageState extends SearchQueryState<CardsPage> {
  @override
  SearchQuery get initialQuery =>
      SearchQuery.cleanWithCategory(DocumentCategory.card);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SyncCubit, SyncState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                DocumentSearchBar(
                  onSearch: querySearch,
                  category: DocumentCategory.card,
                ),
                SliverList.list(
                  children: (state is SyncLoaded)
                      ? state.documents
                          .where(queryFilter)
                          .map((d) => CardsCard(document: d))
                          .toList()
                      : [],
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 1000)), //TODO: Remove
              ],
            );
          },
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
