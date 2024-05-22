package com.videntium.native_download_plugin;

public interface NativeDownloadInterface {
    void onProcess(Integer count, Integer total);

    void onError(Object error);
}
