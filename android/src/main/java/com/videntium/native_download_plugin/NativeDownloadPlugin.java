package com.videntium.native_download_plugin;

import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;
import android.os.Handler;

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
  private final String ERROR_METHOD = "ERROR_METHOD";

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
        Handler handler = new Handler(Looper.getMainLooper());

        String urlPath = call.argument("url_path");
        String filePath = call.argument("file_path");
        NativeDownload nativeDownload = new NativeDownload(urlPath, filePath, new NativeDownloadInterface() {
          @Override
          public void onProcess(Integer count, Integer total) {
            Map<String, Integer> output = new HashMap<String, Integer>();
            Log.i("Download Process", urlPath + " : Count: " + count + " of Total: " + total);
            output.put("count", count);
            output.put("total", total);

            if(count.equals(total)){
              result.success(output);
            }

            handler.post(() -> {
              channel.invokeMethod(PROCESS_METHOD, output);
            });
          }

          @Override
          public void onError(Object error) {
            handler.post(() -> {
              Map<String, Object> output = new HashMap<String, Object>();
              output.put("error", error);
              channel.invokeMethod(ERROR_METHOD, output);
            });
          }
        });
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
