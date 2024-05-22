
import Foundation


class NativeDownloader: NSObject {
    
    private var downloadTask: URLSessionDownloadTask!
    private var backgroundSession: URLSession!
    private var onProcess: ((Int64, Int64) -> Void)?
    private var onError: ((Any) -> Void)?
    private var filePathURL: URL?
    private var filePath: String?

    override init(){
        super.init()
        print("NATIVE DOWNLOADER INITIALIZED")
        let sessionConfig: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "nativeDownloaderSession")
        self.backgroundSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    }
    
    
    func download(urlPath: String, filePath: String, onProcess: @escaping (Int64, Int64) -> Void, onError: @escaping (Any) -> Void){
        self.onError = onError;
        self.onProcess = onProcess
        self.filePath = filePath;
        
        if FileManager.default.fileExists(atPath: filePath) {
            print("File Already Exist");
            onError("File Already Exist");
            return;
        }
        
        self.filePathURL = URL(fileURLWithPath: filePath)
        guard let url: URL = URL(string: urlPath) else {
            print("Invalid URL Address")
            onError("Invalid URL Address");
            return
        }
        print("URL PATH \(urlPath)\nFILE PATH: \(filePath)")
        self.downloadTask = self.backgroundSession.downloadTask(with: url)
        self.downloadTask.resume()
    }
}

extension NativeDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try FileManager.default.moveItem(at: location, to: filePathURL!)
            print("FILE SAVED TO \(String(describing: filePathURL!))")
        } catch let error {
            print("FILE SAVED ERROR \(error)")
            onError?(error)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error: any Error = error {
            print("NATIVE DOWNLOAD ERROR: \(error)")
            onError?(error)
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
        print("ERROR: \(String(describing: error))")
        onError?(error)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("COUNT : \(totalBytesWritten)\nTOTAL: \(totalBytesExpectedToWrite)")
        onProcess?(totalBytesWritten,totalBytesExpectedToWrite)
    }
}
