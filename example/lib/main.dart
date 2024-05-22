import 'package:flutter/material.dart';
import 'package:native_download_plugin/native_download.dart';
import 'package:native_download_plugin_example/file_operation.dart';

void main(List<String> args) {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Native Download',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NativeDownloader nativeDownloader = NativeDownloader();

  Future<void> download() async {
    String path = "https://cloudinary-marketing-res.cloudinary.com/images/w_1000,c_scale/v1679921049/Image_URL_header/Image_URL_header-png?_i=AA";
    final filePath = (await FileOperation.fileDirectory('test8.png')).path;
    await nativeDownloader.download(
      path,
      filePath,
      onProcess: (count, total) {
        print("\nCount: $count of Total: $total");
      },
      onError: (error) {
        print("Error: $error");
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: download,
          child: const Text("Download"),
        ),
      ),
    );
  }
}
