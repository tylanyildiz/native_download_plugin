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


public class NativeDownload {
    private final String urlPath;
    private final String filePath;
    private final NativeDownloadInterface iDownload;

    NativeDownload(String urlPath, String filePath, NativeDownloadInterface iDownload){
        this.urlPath = urlPath;
        this.filePath = filePath;
        this.iDownload = iDownload;
    }

    public void download() {

        long startTime = System.currentTimeMillis();
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        executorService.execute(() -> {
           try{
               URL url = URI.create(urlPath).toURL();
               URLConnection urlConnection = url.openConnection();

               InputStream inputStream = url.openStream();
               FileOutputStream fileOutputStream = new FileOutputStream(filePath);

               byte[] bytes = new byte[1024];
               int count = 0, total = 0;
               int contentLength = urlConnection.getContentLength();

               while ((count = inputStream.read(bytes)) != -1){
                   total += count;
                   iDownload.onProcess(total, contentLength);
                   fileOutputStream.write(bytes, 0, count);
               }
               long endTime = System.currentTimeMillis();
               long duration = endTime - startTime;
               fileOutputStream.close();
               inputStream.close();
               Log.i("Download Time", "Download Completed in " + duration + " ms");
           } catch (Exception exception){
               String exceptionMessage = Objects.requireNonNull(exception.getMessage());
               Log.e("Exception", exceptionMessage);
               iDownload.onError(exception);
           } finally {
               executorService.shutdown();
               Log.i("Download","Downlaod Done: " + urlPath);
           }
        });
    }


    private String getDirectory(String path) {
        File rootFile = Environment.getExternalStoragePublicDirectory(Environment.getRootDirectory().getParent());
        String packageName = BuildConfig.class.getPackage().getName();
        return rootFile.getAbsolutePath() + "/Android/data/" + packageName + "/files/" + path;
    }

}

