package com.videntium.native_download_plugin;

import android.os.Environment;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;


public class NativeDownload {
    private final RNativeDownload rNativeDownload;

    NativeDownload(String urlPath, String filePath, NativeDownloadInterface iDownload){
        rNativeDownload = new RNativeDownload(urlPath, filePath, iDownload);
    }

    public void download() {
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        executorService.execute(() -> {
           try{
               rNativeDownload.run();
           } catch (Exception exception){
               String exceptionMessage = Objects.requireNonNull(exception.getMessage());
               Log.e("Exception", exceptionMessage);
           } finally {
               executorService.shutdown();
           }
        });
    }


    private String getDirectory(String path) {
        File rootFile = Environment.getExternalStoragePublicDirectory(Environment.getRootDirectory().getParent());
        String packageName = BuildConfig.class.getPackage().getName();
        return rootFile.getAbsolutePath() + "/Android/data/" + packageName + "/files/" + path;
    }

}


class RNativeDownload implements  Runnable{

    final String urlPath;
    final String filePath;
    final NativeDownloadInterface iDownload;

    RNativeDownload(String urlPath, String filePath, NativeDownloadInterface iDownload){
        this.urlPath = urlPath;
        this.filePath = filePath;
        this.iDownload = iDownload;
    }

    @Override
    public void run() {
        downloadStreamFile();
    }


    void downloadStreamFile(){
        try {
            URL url = URI.create(urlPath).toURL();
            URLConnection urlConnection = url.openConnection();

            InputStream inputStream = url.openStream();
            FileOutputStream fileOutputStream = new FileOutputStream(filePath);

            byte[] bytes = new byte[1024];
            int count = 0, total = 0;
            int contentLength = urlConnection.getContentLength();

            while ((count = inputStream.read(bytes)) != -1){
                total += count;
                iDownload.process(total, contentLength);
                fileOutputStream.write(bytes, 0, count);
                Thread.sleep(50);
            }

            fileOutputStream.close();
            inputStream.close();
        } catch (Exception exception) {
            Log.e("Exception", String.valueOf(exception.getMessage()));
        }
    }
}

