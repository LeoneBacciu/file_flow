import 'package:file_flow/core/components/common.dart';
import 'package:file_flow/core/components/stateful_indexed_page.dart';
import 'package:file_flow/models/document.dart';
import 'package:flutter/material.dart';

class BankPage extends StatefulIndexedPage {
  const BankPage({
    super.key,
    required super.onRouteChange,
     super.onNewDocument,
  });

  @override
  BankPageState createState() => BankPageState();
}

class BankPageState extends State<BankPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar('Finanze'),
      body: const Center(
        child: Text('Finanze'),
      ),
      floatingActionButton: commonFloatingActionButton(
        context,
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
