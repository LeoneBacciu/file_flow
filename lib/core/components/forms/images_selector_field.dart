import 'dart:io';

import 'package:flutter/material.dart';

import '../../convert.dart';
import '../common.dart';
import 'file_picker_modal.dart';

class ImagesSelectorField extends StatefulWidget {
  final List<File>? initialValue;
  final void Function(List<File>)? onChange;

  final NavigationRoute? heroRoute;

  const ImagesSelectorField({
    super.key,
    this.initialValue,
    this.onChange,
    this.heroRoute,
  });

  @override
  State<ImagesSelectorField> createState() => _ImagesSelectorFieldState();
}

class _ImagesSelectorFieldState extends State<ImagesSelectorField> {
  late final images = widget.initialValue ?? [];

  @override
  Widget build(BuildContext context) {
    final itemCount = images.length;
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: itemCount + 1,
        itemBuilder: (context, index) => (index == itemCount)
            ? _buildLast(context)
            : _buildImage(context, index),
      ),
    );
  }

  Widget _buildLast(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
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
              ).then((f) => addImages(f)),
              child: const Center(
                child: Icon(Icons.add, size: 50),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
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
                    child: Image.file(images[index], fit: BoxFit.cover),
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
                        onPressed: () => deleteImage(index),
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
      ),
    );
  }

  Future<void> addImages(List<File>? result) async {
    if (result != null) {
      final files = await FilesConverter.convert(result);
      setState(() {
        images.addAll(files);
      });
      widget.onChange?.call(images);
    }
  }

  Future<void> editImages(List<File>? result, int index) async {
    if (result != null) {
      final files = await FilesConverter.convert(result);
      setState(() {
        images.removeAt(index);
        images.insertAll(index, files);
      });
      widget.onChange?.call(images);
    }
  }

  Future<void> deleteImage(int index) async {
    setState(() {
      images.removeAt(index);
    });
    widget.onChange?.call(images);
  }
}
