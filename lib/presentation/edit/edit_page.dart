import 'package:file_flow/core/components/common.dart';
import 'package:file_flow/models/document.dart';
import 'package:file_flow/presentation/edit/components/images_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/components/separator.dart';
import '../../state/sync/sync_cubit.dart';
import 'components/content_form.dart';

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
  late Document document = widget.document.edit();

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
              ImagesSelector(
                heroRoute: widget.heroRoute,
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
                duration: const Duration(milliseconds: 500),
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
                        ScaleTransition(scale: animation, child: child),
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
        heroTag: widget.heroRoute,
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
