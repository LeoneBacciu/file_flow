import 'document.dart';

class SearchQuery {
  final String _query;
  final DocumentCategory? _category;

  SearchQuery(this._query, [this._category]);

  SearchQuery.clean()
      : _query = '',
        _category = null;

  SearchQuery.cleanWithCategory(DocumentCategory category)
      : _query = '',
        _category = category;

  bool filter(Document document) {
    return (_category == null || document.category == _category) &&
        document.name.toLowerCase().contains(_query);
  }
}
