import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

class FilesConverter {
  static Future<List<File>> convertImage(File file) async {
    final tmpDir = await getTemporaryDirectory();
    final image = (await img.decodeImageFile(file.path))!;
    return [
      File('${tmpDir.path}/${const Uuid().v4()}.jpeg')
        ..createSync()
        ..writeAsBytesSync(img.encodeJpg(image))
    ];
  }

  static Future<List<File>> convertPdf(File file) async {
    final tmpDir = await getTemporaryDirectory();
    final images = <File>[];

    await for (var page in Printing.raster(file.readAsBytesSync())) {
      print(page);
      images.add(File('${tmpDir.path}/${const Uuid().v4()}.jpeg')
        ..createSync()
        ..writeAsBytesSync(img.encodeJpg(page.asImage())));
    }

    return images;
  }

  static Future<List<File>> convert(List<File> files) =>
      Future.wait(files.map((f) =>
              (extension(f.path) == '.pdf') ? convertPdf(f) : convertImage(f)))
          .then((fs) => fs.expand((fs) => fs))
          .then((fs) => fs.toList());
}
