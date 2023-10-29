import 'package:file_flow/core/components/document_search_bar.dart';
import 'package:file_flow/core/components/stateful_indexed_page.dart';
import 'package:file_flow/core/components/common.dart';
import 'package:file_flow/models/document.dart';
import 'package:file_flow/models/search_query.dart';
import 'package:file_flow/state/search/search_state.dart';
import 'package:file_flow/state/sync/sync_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'components/id_doc_card.dart';

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
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance
  //       .addPostFrameCallback((_) => AuthWrapper.of(context).signIn());
  // }

  SearchQuery _query = SearchQuery.cleanWithCategory(DocumentCategory.card);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SyncCubit, SyncState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              DocumentSearchBar(
                onSearch: (q) => setState(() => _query = q),
                category: DocumentCategory.card,
              ),
              SliverList.list(
                children: (state is SyncLoaded)
                    ? state.documents
                        .where(_query.filter)
                        .map((d) => CardsCard(title: d.name, path: d.preview))
                        .toList()
                    : [],
              ),
            ],
          );
        },
      ),
      floatingActionButton: commonFloatingActionButton(
        context,
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
