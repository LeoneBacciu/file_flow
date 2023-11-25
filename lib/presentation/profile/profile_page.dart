import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/components/common.dart';
import '../../core/components/search/document_search_bar.dart';
import '../../core/components/search/search_context.dart';
import '../../core/components/search/search_notifier.dart';
import '../../core/components/separator.dart';
import '../../core/components/stateful_indexed_page.dart';
import '../../models/document.dart';
import '../../state/sync/sync_cubit.dart';
import '../preview/preview_page.dart';
import 'components/profile_overview.dart';

class ProfilePage extends StatefulIndexedPage {
  const ProfilePage({
    super.key,
    required super.onRouteChange,
    required super.onNewDocument,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final notifier = SearchNotifier();
  final random = Random();

  final colors = List.generate(8, (i) => Colors.blue[(i + 1) * 100]!);

  final heightPercentages = List.generate(8, (i) => (i).toDouble() / 10);

  late final durations =
      List.generate(8, (i) => 30000 + i * 1000 + random.nextInt(1000));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchContext(
        notifier: notifier,
        child: BlocBuilder<SyncCubit, SyncState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async => BlocProvider.of<SyncCubit>(context).load(),
              child: CustomScrollView(
                slivers: [
                  ProfileOverview(),
                  DocumentSearchBar(
                    tags: (state is SyncLoaded)
                        ? state.documents.extractTags()
                        : {},
                  ),
                  SliverList.list(
                    children: (state is SyncLoaded)
                        ? state.documents
                            .unfrozen()
                            .where(SearchContext.of(context).filter)
                            .sorted(SearchContext.of(context).order)
                            .map(
                              (d) => ListTile(
                                leading: Hero(
                                  tag:
                                      '${NavigationRoute.profile}-${d.preview.path}',
                                  child: CircleAvatar(
                                    backgroundImage: FileImage(d.preview),
                                  ),
                                ),
                                trailing: Icon(d.category.iconData),
                                title: Text(d.name),
                                subtitle: Text(DateFormat('HH:mm - dd/MM/yyyy')
                                    .format(d.lastModified)),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PreviewPage(
                                      heroRoute: NavigationRoute.profile,
                                      document: d,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList()
                        : [],
                  ),
                  const SliverToBoxAdapter(child: Separator.height(1000))
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: commonFloatingActionButton(
        context,
        NavigationRoute.profile,
        () => widget.onNewDocument!(DocumentCategory.other),
      ),
      bottomNavigationBar: commonNavigationBar(
        context,
        NavigationRoute.profile,
        widget.onRouteChange,
      ),
    );
  }
}
