import 'package:file_flow/models/document.dart';
import 'package:file_flow/presentation/edit/components/images_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/components/separator.dart';
import '../../state/sync/sync_cubit.dart';
import 'components/content_form.dart';

class EditPage extends StatefulWidget {
  final Document document;

  const EditPage({super.key, required this.document});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late Document document = widget.document.edit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${document.name}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ImagesSelector(
                initialValue: document.files,
                onChange: (fs) =>
                    setState(() => document = document.edit(files: fs)),
              ),
              const Separator.height(30),
              SizedBox(
                width: 300,
                child: TextFormField(
                  initialValue: document.name,
                  onChanged: (s) =>
                      setState(() => document = document.edit(name: s)),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nome Documento',
                  ),
                ),
              ),
              const Separator.height(30),
              AnimatedSwitcher(
                duration: const Duration(seconds: 2),
                child: document.category.parsing && document.files.isNotEmpty
                    ? ContentForm(
                        initialValue: document.content!,
                        source: document.files.first,
                        onChange: (c) => setState(
                            () => document = document.edit(content: c)),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<SyncCubit>(context).editDocument(
            document.edit(lastModified: DateTime.now()),
          );
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
