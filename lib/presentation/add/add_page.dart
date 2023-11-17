import 'dart:io';

import 'package:file_flow/core/translations.dart';
import 'package:file_flow/models/document.dart';
import 'package:file_flow/presentation/add/components/category_dropdown.dart';
import 'package:file_flow/presentation/add/components/content_form.dart';
import 'package:file_flow/presentation/add/components/images_selector.dart';
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
  String name = '';

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
              ImagesSelector(
                onChange: (i) => setState(() => images = i),
              ),
              CategoryDropdown(
                category: category,
                onChange: (c) => setState(() => category = c),
              ),
              const Separator.height(30),
              SizedBox(
                width: 300,
                child: TextFormField(
                  onChanged: (s) => setState(() => name = s),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nome Documento',
                  ),
                ),
              ),
              const Separator.height(30),
              AnimatedSwitcher(
                duration: const Duration(seconds: 2),
                child: category.parsing && images.isNotEmpty
                    ? ContentForm(
                        source: images.first,
                        onChange: (c) => setState(() => documentContent = c),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<SyncCubit>(context).addDocument(
            Document(
              category: category,
              name: name,
              lastModified: DateTime.now(),
              files: images,
              content: documentContent,
            ),
          );
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
