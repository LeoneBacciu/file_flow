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
      body: BlocBuilder<SyncCubit, SyncState>(
        builder: (context, state) {
          print((state is SyncLoaded) ? state.documents.length : null);
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
