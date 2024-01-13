import 'dart:io';

import 'package:flutter/material.dart';

class ImageFullscreen extends StatelessWidget {
  final String tag;
  final File image;

  const ImageFullscreen({super.key, required this.tag, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              clipBehavior: Clip.none,
              minScale: 1,
              maxScale: 5,
              child: Hero(
                tag: tag,
                child: Image.file(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 8,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: ShapeDecoration(
                    color: Theme.of(context).colorScheme.background,
                    shape: const CircleBorder(),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Theme.of(context).colorScheme.onSurface,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
