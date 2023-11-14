import 'package:file_flow/models/document.dart';
import 'package:file_flow/presentation/edit/components/images_selector.dart';
import 'package:flutter/material.dart';

import '../../core/components/separator.dart';
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
    print('---------');
    print(document.content);
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
    );
  }
}
