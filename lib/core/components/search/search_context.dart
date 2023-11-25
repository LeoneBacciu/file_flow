import 'package:flutter/cupertino.dart';

import 'search_notifier.dart';

class SearchContext extends InheritedNotifier<SearchNotifier> {
  const SearchContext({super.key, super.notifier, required super.child});

  static SearchNotifier of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SearchContext>()!.notifier!;
}
