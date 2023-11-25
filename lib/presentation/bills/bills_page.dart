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
import 'components/bill_card.dart';

class BillsPage extends StatefulIndexedPage {
  const BillsPage({
    super.key,
    required super.onRouteChange,
    required super.onNewDocument,
  });

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final notifier = SearchNotifier(DocumentCategory.bill);

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
                            .where((d) => d.category == DocumentCategory.bill)
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
                            .map((d) => BillCard(document: d))
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
        NavigationRoute.bills,
        () => widget.onNewDocument!(DocumentCategory.bill),
      ),
      bottomNavigationBar: commonNavigationBar(
        context,
        NavigationRoute.bills,
        widget.onRouteChange,
      ),
    );
  }
}
