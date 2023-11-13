import 'dart:math';

import 'package:file_flow/core/components/document_search_bar.dart';
import 'package:file_flow/core/components/search_query_state.dart';
import 'package:file_flow/core/components/stateful_indexed_page.dart';
import 'package:file_flow/core/components/common.dart';
import 'package:file_flow/models/document.dart';
import 'package:file_flow/presentation/profile/components/profile_overview.dart';
import 'package:file_flow/state/sync/sync_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulIndexedPage {
  const ProfilePage({
    super.key,
    required super.onRouteChange,
    required super.onNewDocument,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends SearchQueryState<ProfilePage> {
  final random = Random();

  final colors = List.generate(8, (i) => Colors.blue[(i + 1) * 100]!);

  final heightPercentages = List.generate(8, (i) => (i).toDouble() / 10);

  late final durations =
      List.generate(8, (i) => 30000 + i * 1000 + random.nextInt(1000));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SyncCubit, SyncState>(
        listener: (BuildContext context, SyncState state) {
          if (state is SyncLoadedSyncing) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Syncing'),
                duration: Duration(days: 365),
              ),
            );
          } else if (state is SyncLoadedOffline) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Offline'),
                duration: Duration(days: 365),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).clearSnackBars();
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              ProfileOverview(),
              DocumentSearchBar(onSearch: querySearch),
              SliverList.list(
                children: (state is SyncLoaded)
                    ? state.documents
                        .where(queryFilter)
                        .map((d) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: FileImage(d.preview),
                              ),
                              trailing: IconButton(
                                onPressed: () =>
                                    BlocProvider.of<SyncCubit>(context)
                                        .deleteDocument(d),
                                icon: const Icon(Icons.delete),
                              ),
                              title: Text(d.name),
                              subtitle: Text(d.category.jsonValue),
                              onTap: () {},
                            ))
                        .toList()
                    : [],
              ),
            ],
          );
        },
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