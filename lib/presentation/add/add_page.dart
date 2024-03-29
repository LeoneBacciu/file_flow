import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/components/forms/category_dropdown_field.dart';
import '../../core/components/forms/content_form_field.dart';
import '../../core/components/forms/filename_text_field.dart';
import '../../core/components/forms/images_selector_field.dart';
import '../../core/components/forms/tag_selector_field.dart';
import '../../core/components/separator.dart';
import '../../models/document.dart';
import '../../state/sync/sync_cubit.dart';

class AddPage extends StatefulWidget {
  final DocumentCategory category;
  final List<File> initialImages;

  const AddPage({
    super.key,
    required this.category,
    this.initialImages = const [],
  });

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late List<File> images = widget.initialImages;
  late DocumentCategory category = widget.category;
  Set<String> tags = {};
  String? name;
  DocumentContent? documentContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiungi ${category.displayName}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ImagesSelectorField(
                initialValue: images,
                onChange: (i) => setState(() => images = i),
              ),
              CategoryDropdownField(
                initialValue: category,
                onChange: (c) => setState(() => category = c),
              ),
              const Separator.height(30),
              FilenameTextField(
                onChange: (s) => (name = s),
              ),
              const Separator.height(30),
              TagSelectorField(
                defaultTags: category.defaultTags,
                onChange: (t) => (tags = t),
              ),
              const Separator.height(30),
              if (category.parsing && images.isNotEmpty)
                ContentFormField(
                  source: images.first,
                  onChange: (c) => (documentContent = c),
                ),
              const Separator.height(100),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
                onPressed: () {
                  if (name == null || (name?.isEmpty ?? false)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Il nome non può essere vuoto')),
                    );
                    return;
                  }
                  if (images.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inserisci almeno un file')),
                    );
                    return;
                  }
                  if (category.parsing && documentContent == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inserisci i metadati')),
                    );
                    return;
                  }
                  BlocProvider.of<SyncCubit>(context).addDocument(
                    Document(
                      category: category,
                      tags: tags,
                      name: name!,
                      lastModified: DateTime.now(),
                      files: images,
                      content: documentContent,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.save),
              )),
    );
  }
}
