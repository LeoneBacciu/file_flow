import 'package:file_flow/core/functions.dart';
import 'package:file_flow/models/document.dart';
import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  final DocumentCategory category;

  const AddPage({super.key, required this.category});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final PageController _controller = PageController(viewportFraction: 0.8);
  int itemCount = 3;
  late DocumentCategory category = widget.category;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 300, // Card height
                  child: PageView.builder(
                    itemCount: itemCount,
                    controller: _controller,
                    itemBuilder: (context, index) {
                      if (index == itemCount - 1) {
                        return Center(
                          child: AspectRatio(
                            aspectRatio: 85.60 / 53.98,
                            child: Card(
                              elevation: 4,
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                onTap: () => print('add'),
                                child: const Center(
                                  child: Icon(Icons.add, size: 50),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Center(
                        child: AspectRatio(
                          aspectRatio: 85.60 / 53.98,
                          child: Card(
                            elevation: 4,
                            clipBehavior: Clip.hardEdge,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset('assets/id_card.jpeg'),
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => print('edit ${index}'),
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(0),
                                        ),
                                        child: const Icon(Icons.edit),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            print('delete ${index}'),
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(8),
                                        ),
                                        child: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownMenu<DocumentCategory>(
                    width: 300,
                    initialSelection: category,
                    onSelected: (value) => setState(() => category = value!),
                    dropdownMenuEntries: DocumentCategory.list().map((value) {
                      return DropdownMenuEntry<DocumentCategory>(
                          value: value, label: value.jsonValue.capitalize());
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nome Documento',
                      hintText: 'Nome Documento',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => print('submit'),
          child: const Icon(Icons.save),
        ),
      ),
      onWillPop: () async => true,
    );
  }
}
