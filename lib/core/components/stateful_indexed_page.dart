import 'package:file_flow/core/components/common.dart';
import 'package:file_flow/models/document.dart';
import 'package:flutter/material.dart';

abstract class StatefulIndexedPage extends StatefulWidget {
  final void Function(NavigationRoute) onRouteChange;
  final void Function(DocumentCategory)? onNewDocument;

  const StatefulIndexedPage({
    super.key,
    required this.onRouteChange,
    this.onNewDocument,
  });
}
