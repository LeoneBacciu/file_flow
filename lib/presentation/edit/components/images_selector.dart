import 'dart:io';

import 'package:file_flow/core/components/file_picker_modal.dart';
import 'package:file_flow/core/convert.dart';
import 'package:flutter/material.dart';

import '../../../core/components/common.dart';

class ImagesSelector extends StatefulWidget {
  final void Function(List<File>) onChange;
  final List<File> initialValue;

  final NavigationRoute heroRoute;

  const ImagesSelector({
    super.key,
    required this.onChange,
    required this.initialValue,
    required this.heroRoute,
  });

  @override
  State<ImagesSelector> createState() => _ImagesSelectorState();
}

class _ImagesSelectorState extends State<ImagesSelector> {
  final PageController _controller = PageController(viewportFraction: 0.8);
  late List<File> images = widget.initialValue;

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
                    onTap: () => showModalBottomSheet<List<File>>(
                      context: context,
                      builder: (context) => const FilePickerModal(),
                    ).then(addImages),
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
                      child: Hero(
                        tag: '${widget.heroRoute}-${images[index].path}',
                        child: Image.file(images[index]),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => showModalBottomSheet<List<File>>(
                              context: context,
                              builder: (context) => const FilePickerModal(),
                            ).then((f) => editImages(f, index)),
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: const Icon(Icons.edit),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                update(() => images.removeAt(index)),
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

  Future<void> addImages(List<File>? result) async {
    if (result != null) {
      final files = await FilesConverter.convert(result);
      update(() => images.addAll(files));
    }
  }

  Future<void> editImages(List<File>? result, int index) async {
    if (result != null) {
      final files = await FilesConverter.convert(result);
      update(() {
        images.removeAt(index);
        images.insertAll(index, files);
      });
    }
  }
}
