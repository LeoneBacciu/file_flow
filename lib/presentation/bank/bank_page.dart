import 'package:flutter/material.dart';

import '../../core/components/common.dart';
import '../../core/components/stateful_indexed_page.dart';
import '../../models/document.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar('Finanze'),
      body: const Center(
        child: Text('Available soon!'),
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
