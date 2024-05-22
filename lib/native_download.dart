import 'dart:io';
import 'package:flutter/services.dart';
part 'native_download_interface.dart';

/// Native Channel
const String _nativeChannel = "NATIVE_DOWNLOAD_CHANNEL";

/// Download method call
const String _downloadMethod = "DOWNLOAD_METHOD";

/// Download method call
const String _downloadProcessMethod = "PROCESS_METHOD";

/// Download error method call
const String _errorDownloadMethod = "ERROR_METHOD";

final class NativeDownloader implements INativeDownloader {
  /// Native Channel
  final MethodChannel _channel;

  @override
  String? baseUrl;

  /// Constructor of [NativeDownloader]
  ///
  /// [baseUrl]
  NativeDownloader({
    this.baseUrl,
  }) : _channel = const MethodChannel(_nativeChannel);

  @override
  Future<File?> download(
    String urlPath,
    String filePath, {
    void Function(int count, int total)? onProcess,
    void Function(dynamic error)? onError,
  }) async {
    String? downloadPath;
    if (baseUrl?.isNotEmpty ?? false) downloadPath = "$baseUrl/$urlPath";
    downloadPath ??= urlPath;

    _channel.setMethodCallHandler((call) async {
      if (call.method == _downloadProcessMethod) {
        Map? output = call.arguments;
        if (output != null) {
          onProcess?.call(output['total']!, output['count']!);
        }
      }

      if (call.method == _errorDownloadMethod) {
        final error = call.arguments;
        onError?.call(error);
      }
    });

    await _channel.invokeMapMethod(_downloadMethod, {
      'url_path': downloadPath,
      'file_path': filePath,
    });
    return File(filePath);
  }
}
