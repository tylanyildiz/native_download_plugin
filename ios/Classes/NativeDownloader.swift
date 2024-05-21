
import Foundation


class NativeDownloader: NSObject {
    private var downloadTask: URLSessionDownloadTask!
    private var backgroundSession: URLSession!
    private var process: ((Int64, Int64) -> Void)?
    private var filePathURL: URL?

    override init(){
        super.init()
        print("NATIVE DOWNLOADER INITIALIZED")
        let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "nativeDownloaderSession")
        self.backgroundSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    }
    
    
    func download(urlPath: String, filePath: String, process: @escaping (Int64, Int64) -> Void){
        self.process = process
        self.filePathURL = URL(fileURLWithPath: filePath)
        guard let url: URL = URL(string: urlPath) else {
            print("Invalid URL Address")
            return
        }
        print("URL PATH \(urlPath) || FILE PATH: \(filePath)")
        self.downloadTask = self.backgroundSession.downloadTask(with: url)
        self.downloadTask.resume()
    }
}

extension NativeDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try FileManager.default.moveItem(at: location, to: filePathURL!)
            print("FILE SAVED TO \(String(describing: filePathURL!))")
        } catch {
            print("FILE SAVED ERROR")
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error: any Error = error {
            print("NATIVE DOWNLOAD ERROR: \(error)")
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
        print("ERROR: \(String(describing: error))")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("COUNT : \(totalBytesWritten)\nTOTAL: \(totalBytesExpectedToWrite)")
        process?(totalBytesWritten,totalBytesExpectedToWrite)
    }
}
