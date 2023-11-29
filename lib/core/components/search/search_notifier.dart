import 'package:flutter/material.dart';

import '../../../models/document.dart';
import '../../date_misc.dart';
import '../../functions.dart';

enum SearchSortPolicy {
  lastModified('Ultima Modifica'),
  date('Data', true),
  amount('Costo', true);

  final String displayName;
  final bool requireParsing;

  const SearchSortPolicy(this.displayName, [this.requireParsing = false]);

  static List<SearchSortPolicy> listForCategory([DocumentCategory? category]) =>
      values
          .where((sp) => !sp.requireParsing || category?.parsing == true)
          .toList();
}

class SearchNotifier extends ChangeNotifier {
  String _query = '';
  DocumentCategory? _category;
  final bool _lockedCategory;

  TagSet _tags = {};

  bool _descending = true;

  SearchSortPolicy _policy = SearchSortPolicy.lastModified;

  DateTimeRange? _dateTimeRage;

  SearchNotifier([this._category]) : _lockedCategory = _category != null;

  String get query => _query;

  set query(String q) {
    _query = q;
    notifyListeners();
  }

  DocumentCategory? get category => _category;

  set category(DocumentCategory? c) {
    if (!_lockedCategory) {
      _category = c;
      if (category?.parsing != true) _policy = SearchSortPolicy.lastModified;
      notifyListeners();
    }
  }

  bool get lockedCategory => _lockedCategory;

  TagSet get tags => _tags;

  set tags(TagSet t) {
    _tags = t.toSet();
    notifyListeners();
  }

  void addTag(String t) {
    tags.add(t);
    notifyListeners();
  }

  void removeTag(String t) {
    tags.remove(t);
    notifyListeners();
  }

  void toggleTag(String t, bool add) {
    add ? tags.add(t) : tags.remove(t);
    notifyListeners();
  }

  bool get descending => _descending;

  set descending(bool d) {
    _descending = d;
    notifyListeners();
  }

  SearchSortPolicy get sortPolicy => _policy;

  set sortPolicy(SearchSortPolicy p) {
    if (!p.requireParsing || category?.parsing == true) {
      _policy = p;
      notifyListeners();
    }
  }

  DateTimeRange? get dateTimeRange => _dateTimeRage;

  set dateTimeRange(DateTimeRange? dateTimeRange) {
    _dateTimeRage = dateTimeRange;
    notifyListeners();
  }

  bool filter(Document document) {
    if (category != null && document.category != category) {
      return false;
    }
    if (!document.name.toLowerCase().contains(query.toLowerCase())) {
      return false;
    }
    if (!document.tags.containsAll(tags)) {
      return false;
    }
    if (dateTimeRange != null &&
        document.content?.date.apply(dateTimeRange!.contains) == false) {
      return false;
    }
    return true;
  }

  int order(Document a, Document b) {
    final aVal = switch (sortPolicy) {
      SearchSortPolicy.amount => a.content!.amount,
      SearchSortPolicy.date => a.content!.date,
      _ => a.lastModified,
    } as Comparable<Object>;
    final bVal = switch (sortPolicy) {
      SearchSortPolicy.amount => b.content!.amount,
      SearchSortPolicy.date => b.content!.date,
      _ => b.lastModified,
    } as Comparable<Object>;
    return descending ? bVal.compareTo(aVal) : aVal.compareTo(bVal);
  }
}
