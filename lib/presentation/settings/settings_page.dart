import 'package:file_flow/core/components/common.dart';
import 'package:file_flow/core/components/stateful_indexed_page.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../repositories/drive_repository.dart';
import '../../repositories/sync_repository.dart';

class SettingsPage extends StatefulIndexedPage {
  const SettingsPage({super.key, required super.onRouteChange});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Impostazioni'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                GetIt.instance<DriveRepository>().deleteAll();
              },
              child: const Text(
                'Reset Remote',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                GetIt.instance<SyncRepository>().clearAll();
              },
              child: const Text('Reset Local'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: commonNavigationBar(
        context,
        NavigationRoute.settings,
        widget.onRouteChange,
      ),
    );
  }
}
