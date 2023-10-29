import 'package:file_flow/models/document.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchState with ChangeNotifier {
  String _query = '';
  final DocumentCategory? _category;

  SearchState([this._category]);

  static Widget provider({required Widget child, DocumentCategory? category}) =>
      ChangeNotifierProvider(
        create: (_) => SearchState(category),
        child: child,
      );

  static Widget consumer(
    Widget Function(BuildContext context, SearchState value) builder,
  ) =>
      Consumer<SearchState>(
        builder: (context, value, _) => builder(context, value),
      );

  void submit(String query) {
    print(query);
    _query = query;
    notifyListeners();
  }

  bool filter(Document document) {
    return (_category == null || document.category == _category) &&
        document.name.toLowerCase().contains(_query);
  }
}
