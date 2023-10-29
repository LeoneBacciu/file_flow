import 'package:flutter/material.dart';

class SearchWrapper extends InheritedWidget {
  final query = '';

  SearchWrapper({super.key, required super.child});


  static SearchWrapper? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SearchWrapper>();
  }

  static SearchWrapper of(BuildContext context) {
    final SearchWrapper? result = maybeOf(context);
    assert(result != null, 'No AuthWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SearchWrapper oldWidget) => oldWidget.query != query;
}
