import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MediaStorage {
  static Future<String> ensureLocalPath(String inputPath) async {
    if (inputPath.startsWith('file://')) {
      return Uri.parse(inputPath).toFilePath();
    }
    if (inputPath.startsWith('content://')) {
      final dir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(dir.path, 'photos'));
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }
      final x = XFile(inputPath);
      final ext =
          p.extension(inputPath).isNotEmpty ? p.extension(inputPath) : '.jpg';
      final outPath = p.join(
          photosDir.path, 'photo_${DateTime.now().millisecondsSinceEpoch}$ext');

      await x.saveTo(outPath);
      return outPath;
    }
    return inputPath;
  }
}
