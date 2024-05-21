part of 'native_download.dart';

abstract interface class INativeDownloader {
  String? baseUrl;

  Future<File?> download(
    String urlPath,
    String filePath, {
    void Function(int count, int total)? process,
  });
}
