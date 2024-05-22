# native_download_plugin

```dart
final NativeDownloader nativeDownloader = NativeDownloader(
    baseUrl: // default url
);

nativeDownloader.download(
    urlPath, // download url
    filePath, // file path
    onProcess: (count, total) {
        // Process
    },
    onError: (error) {
        // Error
    }
);
```

