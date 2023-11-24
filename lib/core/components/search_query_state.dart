import 'package:flutter/material.dart';

import '../../models/document.dart';
import '../../models/search_query.dart';

abstract class SearchQueryState<T extends StatefulWidget> extends State<T> {
  late SearchQuery _query = initialQuery;

  SearchQuery get initialQuery => SearchQuery.clean();

  void querySearch(SearchQuery query) => setState(() => _query = query);

  bool queryFilter(Document document) => _query.filter(document);

  int querySort(Document a, Document b) => b.lastModified.compareTo(a.lastModified);
}
