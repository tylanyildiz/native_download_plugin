import Flutter
import UIKit

public class NativeDownloadPlugin: NSObject, FlutterPlugin {


  let nativeChannel: FlutterMethodChannel;
    
    init(nativeChannel: FlutterMethodChannel) {
        self.nativeChannel = nativeChannel
    }

  public static func register(with registrar: FlutterPluginRegistrar) {
      
    let channel = FlutterMethodChannel(name: "NATIVE_DOWNLOAD_CHANNEL", binaryMessenger: registrar.messenger())
    let instance = NativeDownloadPlugin(nativeChannel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "DOWNLOAD_METHOD":
      guard let args = call.arguments as? [String: String],
          let urlPath = args["url_path"],
          let filePath = args["file_path"]  else {
              result(["error": "Invalid arguments"])
              return
        }
      let nativeDonwnloader = NativeDownloader()
      nativeDonwnloader.download(urlPath: urlPath, filePath: filePath) { count, total in 
        let output = ["count": count, total: total]
        self.nativeChannel.invokeMethod("PROCESS_METHOD", arguments: output)
        if(count == total) {
          result(output)
        }
      }
      break;
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

