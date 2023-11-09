import 'package:file_flow/core/components/stateful_indexed_page.dart';
import 'package:file_flow/core/components/common.dart';
import 'package:file_flow/models/document.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar('Bollette'),
      body: const Center(
        child: Text('Bollette'),
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
