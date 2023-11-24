import 'dart:io';

import 'package:file_flow/core/components/forms/category_dropdown_field.dart';
import 'package:file_flow/core/components/forms/content_form_field.dart';
import 'package:file_flow/core/components/forms/filename_text_field.dart';
import 'package:file_flow/core/components/forms/images_selector_field.dart';
import 'package:file_flow/core/components/forms/tag_selector_field.dart';
import 'package:file_flow/core/translations.dart';
import 'package:file_flow/models/document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/components/separator.dart';
import '../../state/sync/sync_cubit.dart';

class AddPage extends StatefulWidget {
  final DocumentCategory category;

  const AddPage({super.key, required this.category});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<File> images = [];
  late DocumentCategory category = widget.category;
  Set<String> tags = {};
  String? name;
  DocumentContent? documentContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiungi ${translateCategory[category.jsonValue]!}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ImagesSelectorField(
                onChange: (i) => setState(() => images = i),
              ),
              CategoryDropdownField(
                initialValue: category,
                onChange: (c) => setState(() => category = c),
              ),
              const Separator.height(30),
              FilenameTextField(
                onChange: (s) => setState(() => name = s),
              ),
              const Separator.height(30),
              TagSelectorField(
                onChange: (t) => setState(() => tags = t),
              ),
              const Separator.height(30),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
                        ScaleTransition(scale: animation, child: child),
                child: category.parsing && images.isNotEmpty
                    ? ContentFormField(
                        source: images.first,
                        onChange: (c) => setState(() => documentContent = c),
                      )
                    : const SizedBox(),
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
