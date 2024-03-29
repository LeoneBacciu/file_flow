import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/components/common.dart';
import 'image_fullscreen.dart';

class ImagesPreview extends StatelessWidget {
  final List<File> images;

  final NavigationRoute heroRoute;

  const ImagesPreview({
    super.key,
    required this.images,
    required this.heroRoute,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: images.length,
      itemBuilder: (context, index) => Center(
        child: InkWell(
          onLongPress: () => Share.shareXFiles(
            [XFile(images[index].path)],
          ),
          child: Card(
            elevation: 4,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Hero(
              tag: '$heroRoute-${images[index].path}',
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ImageFullscreen(
                      tag: '$heroRoute-${images[index].path}',
                      image: images[index],
                    ),
                  ),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(images[index])),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
