import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

abstract final class FileOperation {
  FileOperation._();

  /// Create new directory at the specified [path]
  /// returns directory
  static Future<Directory> fileDirectory([String? path]) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      appDocDir = (await getExternalStorageDirectory())!;
    }
    if (path == null) return appDocDir;
    final appDocPath = appDocDir.path;
    final dirPath = join(appDocPath, path);
    return Directory(dirPath);
  }

  /// Create a subdirectory at the specified [path] if it does not already exist
  /// returns the path of new direcotry
  static Future<String> createSubDirectory(String path) async {
    try {
      final newDirectory = await fileDirectory(path);
      if (!await newDirectory.exists()) await newDirectory.create();
      return newDirectory.path;
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Remove a subdirectory at the specified [path]
  /// returns a boolean indicating whether operation was successful.
  static Future<bool> removeSubDirectory(String path) async {
    try {
      final newDirectory = await fileDirectory(path);
      if (newDirectory.existsSync()) await newDirectory.delete(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check a subdirectory at the specified [path] exist
  static Future<bool> existFolder(String path) async {
    final directory = await fileDirectory(path);
    return directory.exists();
  }

  /// Check a subdirectory at the specified [path] exist
  static Future<bool> existFile(String path) async {
    final directory = await fileDirectory(path);
    return File(directory.path).exists();
  }
}
