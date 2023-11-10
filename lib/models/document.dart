import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart';

enum DocumentCategory {
  card('card'),
  bill('bill', true),
  bank('bank', true),
  other('other');

  final String jsonValue;
  final bool parsing;

  const DocumentCategory(this.jsonValue, [this.parsing = false]);

  factory DocumentCategory.fromJson(String json) =>
      values.firstWhere((e) => e.jsonValue == json);

  static List<DocumentCategory> list() => [
        DocumentCategory.card,
        DocumentCategory.bill,
        DocumentCategory.bank,
        DocumentCategory.other
      ];
}

class Document extends Equatable {
  final DocumentCategory category;
  final String name;
  final DateTime lastModified;
  final List<File> files;
  final DocumentContent? content;

  const Document({
    required this.category,
    required this.name,
    required this.lastModified,
    required this.files,
    this.content,
  });

  File get preview => files.first;

  Document.fromJson(Map<String, dynamic> json, File Function(String) fileHandle)
      : category = DocumentCategory.fromJson(json['category']),
        name = json['name'],
        lastModified = DateTime.parse(json['last_modified']),
        files = List.castFrom<dynamic, String>(json['files'])
            .map(fileHandle)
            .toList(),
        content = json.containsKey('content')
            ? DocumentContent.fromJson(json['content'])
            : null,
        assert(json.containsKey('content') |
            !DocumentCategory.fromJson(json['category']).parsing);

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['category'] = category.jsonValue;
    data['name'] = name;
    data['last_modified'] = lastModified.toIso8601String();
    data['files'] = files.map((f) => basename(f.path)).toList();
    if (content != null) data['content'] = content!.toJson();
    return data;
  }

  @override
  List<Object?> get props => [category, name, lastModified, files, content];
}

class DocumentContent extends Equatable {
  final DateTime date;
  final double amount;
  final List<Uri> urls;

  const DocumentContent({
    required this.date,
    required this.amount,
    required this.urls,
  });

  DocumentContent.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json['date']),
        amount = json['amount'],
        urls = List.castFrom(json['urls']).map((e) => Uri.parse(e)).toList();

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date.toIso8601String();
    data['amount'] = amount;
    data['urls'] = urls.map((e) => e.toString()).toList();
    return data;
  }

  @override
  List<Object?> get props => [date, amount, urls];
}
