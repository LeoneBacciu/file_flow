import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/components/common.dart';
import '../../core/components/forms/content_form_field.dart';
import '../../core/components/forms/filename_text_field.dart';
import '../../core/components/forms/images_selector_field.dart';
import '../../core/components/forms/tag_selector_field.dart';
import '../../core/components/separator.dart';
import '../../models/document.dart';
import '../../state/sync/sync_cubit.dart';

class EditPage extends StatefulWidget {
  final Document document;
  final NavigationRoute heroRoute;

  const EditPage({
    super.key,
    required this.document,
    required this.heroRoute,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late Document document = widget.document.copyWith();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica ${document.name}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ImagesSelectorField(
                heroRoute: widget.heroRoute,
                initialValue: document.files,
                onChange: (fs) => setState(
                  () => document = document.copyWith(files: fs),
                ),
              ),
              const Separator.height(30),
              FilenameTextField(
                initialValue: document.name,
                onChange: (s) => (document = document.copyWith(name: s)),
              ),
              const Separator.height(30),
              TagSelectorField(
                defaultTags: document.category.defaultTags.union(document.tags),
                initialValue: document.tags,
                onChange: (t) => (document = document.copyWith(tags: t)),
              ),
              const Separator.height(30),
              if (document.category.parsing && document.files.isNotEmpty)
                ContentFormField(
                  source: document.files.first,
                  initialValue: document.content!,
                  onChange: (c) => (document = document.copyWith(content: c)),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: widget.heroRoute,
        onPressed: () {
          BlocProvider.of<SyncCubit>(context).editDocument(
            document.copyWith(lastModified: DateTime.now()),
          );
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
