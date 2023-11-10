import 'package:file_flow/core/components/common.dart';
import 'package:file_flow/core/components/stateful_indexed_page.dart';
import 'package:flutter/material.dart';

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
      bottomNavigationBar: commonNavigationBar(
        context,
        NavigationRoute.settings,
        widget.onRouteChange,
      ),
    );
  }
}
