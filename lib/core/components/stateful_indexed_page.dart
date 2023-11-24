import 'package:flutter/material.dart';

import '../../models/document.dart';
import 'common.dart';

abstract class StatefulIndexedPage extends StatefulWidget {
  final void Function(NavigationRoute) onRouteChange;
  final void Function(DocumentCategory)? onNewDocument;

  const StatefulIndexedPage({
    super.key,
    required this.onRouteChange,
    this.onNewDocument,
  });
}
