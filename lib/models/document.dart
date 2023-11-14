import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_flow/core/functions.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

typedef DocumentListEditable = List<Document>;
typedef DocumentList = UnmodifiableListView<Document>;

enum DocumentCategory {
  card('card', 'Carta', Icons.info),
  bill('bill', 'Bolletta', Icons.home, true),
  bank('bank', 'Banca', Icons.attach_money, true),
  other('other', 'Altro', Icons.description);

  final String jsonValue;
  final String displayName;
  final IconData iconData;
  final bool parsing;

  const DocumentCategory(this.jsonValue, this.displayName, this.iconData,
      [this.parsing = false]);

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
  final String uuid;
  final DocumentCategory category;
  final String name;
  final DateTime lastModified;
  final List<File> files;
  final DocumentContent? content;

  Document({
    required this.category,
    required this.name,
    required this.lastModified,
    required this.files,
    this.content,
  }) : uuid = uuid4();

  const Document.uuid({
    required this.uuid,
    required this.category,
    required this.name,
    required this.lastModified,
    required this.files,
    this.content,
  });

  Document edit({
    String? uuid,
    DocumentCategory? category,
    String? name,
    DateTime? lastModified,
    List<File>? files,
    DocumentContent? content,
  }) =>
      Document.uuid(
        uuid: uuid ?? this.uuid,
        category: category ?? this.category,
        name: name ?? this.name,
        lastModified: lastModified ?? this.lastModified,
        files: files ?? [...this.files],
        content: content ?? this.content,
      );

  File get preview => files.first;

  Document.fromJson(Map<String, dynamic> json, File Function(String) fileHandle)
      : uuid = json['id'],
        category = DocumentCategory.fromJson(json['category']),
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
    data['id'] = uuid;
    data['category'] = category.jsonValue;
    data['name'] = name;
    data['last_modified'] = lastModified.toIso8601String();
    data['files'] = files.map((f) => basename(f.path)).toList();
    if (content != null) data['content'] = content!.toJson();
    return data;
  }

  @override
  List<Object?> get props =>
      [uuid, category, name, lastModified, files, content];

  static DocumentListEditable deserialize(
          String data, File Function(String) fileHandler) =>
      List.from(json.decode(data))
          .map((d) => Document.fromJson(d, fileHandler))
          .toList();
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

extension DocumentListExtension on DocumentListEditable {
  List<File> getFiles() => expand((d) => d.files).toList();

  Document? getUuid(String uuid) =>
      cast<Document?>().firstWhere((d) => d!.uuid == uuid, orElse: () => null);

  void merge(DocumentListEditable other) {
    for (final od in other) {
      final conflict = getUuid(od.uuid);
      if (conflict == null || conflict.lastModified.isAfter(od.lastModified)) {
        add(od);
      }
    }
  }

  void replaceUuid(Document document) =>
      this[indexWhere((d) => d.uuid == document.uuid)] = document;

  String serialize() => json.encode(map((d) => d.toJson()).toList());

  DocumentListEditable sorted(int Function(Document a, Document b) compare) {
    sort(compare);
    return this;
  }

  DocumentList frozen() => UnmodifiableListView(this);
}

extension DocumentListUExtension on DocumentList {
  DocumentListEditable unfrozen() => toList();
}

extension DocumentsFileExtension on List<File> {
  bool containsPath(String path) =>
      cast<File?>().firstWhere((f) => f!.path == path, orElse: () => null) !=
      null;

  bool containsFilename(String name) =>
      cast<File?>()
          .firstWhere((f) => basename(f!.path) == name, orElse: () => null) !=
      null;
}
