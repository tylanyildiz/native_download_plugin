import 'dart:io';
import 'package:flutter/services.dart';
part 'native_download_interface.dart';

/// Native Channel
const String _nativeChannel = "NATIVE_DOWNLOAD_CHANNEL";

/// Download method call
const String _downloadMethod = "DOWNLOAD_METHOD";

/// Download method call
const String _downloadProcessMethod = "PROCESS_METHOD";

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
  Future<File?> download(String urlPath, String filePath, {void Function(int count, int total)? process}) async {
    String? downloadPath;
    if (baseUrl?.isNotEmpty ?? false) downloadPath = "$baseUrl/$urlPath";
    downloadPath ??= urlPath;

    _channel.setMethodCallHandler((call) async {
      if (call.method == _downloadProcessMethod) {
        Map? output = call.arguments;
        if (output != null) {
          process?.call(output['total']!, output['count']!);
        }
      }
    });

    await _channel.invokeMapMethod(_downloadMethod, {
      'url_path': downloadPath,
      'file_path': filePath,
    });
    return File(filePath);
  }
}
