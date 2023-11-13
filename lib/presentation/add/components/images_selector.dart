import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImagesSelector extends StatefulWidget {
  final void Function(List<File>) onChange;
  final List<File>? initialImages;

  const ImagesSelector({super.key, required this.onChange, this.initialImages});

  @override
  State<ImagesSelector> createState() => _ImagesSelectorState();
}

class _ImagesSelectorState extends State<ImagesSelector> {
  final PageController _controller = PageController(viewportFraction: 0.8);
  late List<File> images = widget.initialImages ?? [];

  void update(VoidCallback fn) {
    setState(fn);
    widget.onChange(images);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      update(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Card height
      child: PageView.builder(
        itemCount: images.length + 1,
        controller: _controller,
        itemBuilder: (context, index) {
          if (index == images.length) {
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
                    onTap: addImage,
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
                      child: Image.file(images[index]),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => print('edit $index'),
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: const Icon(Icons.edit),
                          ),
                          ElevatedButton(
                            onPressed: () => update(() => images.removeAt(index)),
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
    );
  }

  void addImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      update(() {
        images.add(File(result.paths.first!));
      });
    }
  }
}
