import 'package:file_flow/core/components/document_search_bar.dart';
import 'package:file_flow/core/components/search_query_state.dart';
import 'package:file_flow/core/components/stateful_indexed_page.dart';
import 'package:file_flow/core/components/common.dart';
import 'package:file_flow/models/document.dart';
import 'package:file_flow/models/search_query.dart';
import 'package:file_flow/presentation/bills/components/bill_card.dart';
import 'package:file_flow/state/sync/sync_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillsPage extends StatefulIndexedPage {
  const BillsPage({
    super.key,
    required super.onRouteChange,
    required super.onNewDocument,
  });

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends SearchQueryState<BillsPage> {
  @override
  SearchQuery get initialQuery =>
      SearchQuery.cleanWithCategory(DocumentCategory.bill);

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
                  category: DocumentCategory.bill,
                ),
                SliverList.list(
                  children: (state is SyncLoaded)
                      ? state.documents
                      .where(queryFilter)
                      .map((d) => BillCard(document: d))
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
