package com.videntium.native_download_plugin;

import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Handler;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** NativeDownloadPlugin */
public class NativeDownloadPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private final String NATIVE_CHANNEL = "NATIVE_DOWNLOAD_CHANNEL";
  private final String DOWNLOAD_METHOD = "DOWNLOAD_METHOD";
  private final String PROCESS_METHOD = "PROCESS_METHOD";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), NATIVE_CHANNEL);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String method = call.method;
    switch (method){
      case DOWNLOAD_METHOD:
        android.os.Handler handler = new android.os.Handler(Looper.getMainLooper());

        String urlPath = call.argument("url_path");
        String filePath = call.argument("file_path");
        NativeDownloadInterface iDownload = (count, total) -> {
          Map<String, Integer> output = new HashMap<String, Integer>();
          Log.i("Download Process", "Count: " + count + "of Total: " + total);
          output.put("count", count);
          output.put("total", total);
          if(count.equals(total)){
            result.success(output);
          }
          handler.post(() -> {
            channel.invokeMethod(PROCESS_METHOD, output);
          });
        };
        NativeDownload nativeDownload = new NativeDownload(urlPath, filePath, iDownload);
        nativeDownload.download();
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
