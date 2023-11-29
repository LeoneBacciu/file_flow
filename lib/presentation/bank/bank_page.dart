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
import 'components/bank_card.dart';
import 'components/bank_plot.dart';

class BankPage extends StatefulIndexedPage {
  const BankPage({
    super.key,
    required super.onRouteChange,
    super.onNewDocument,
  });

  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  final notifier = SearchNotifier(DocumentCategory.bank);

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
                            .where((d) => d.category == DocumentCategory.bank)
                            .toList()
                            .extractTags()
                        : {},
                  ),
                  if (state is SyncLoaded)
                    BankPlot(
                      documents: state.documents
                          .where(SearchContext.of(context).filter)
                          .toList()
                          .frozen(),
                    ),
                  SliverList.list(
                    children: (state is SyncLoaded)
                        ? state.documents
                            .unfrozen()
                            .where(SearchContext.of(context).filter)
                            .sorted(SearchContext.of(context).order)
                            .map((d) => BankCard(document: d))
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
        NavigationRoute.bank,
        () => widget.onNewDocument!(DocumentCategory.bank),
      ),
      bottomNavigationBar: commonNavigationBar(
        context,
        NavigationRoute.bank,
        widget.onRouteChange,
      ),
    );
  }
}
