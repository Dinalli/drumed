//
//  DownloadHelper.swift
//  Drumed
//
//  Created by Andrew Donnelly on 05/06/2020.
//  Copyright © 2020 Andrew Donnelly. All rights reserved.
//

import UIKit

public protocol DownloadHelperDelegate: AnyObject {
    func DownloadComplete()
    func DownloadFailed()
}

class DownloadHelper: NSObject {

    weak var delegate: DownloadHelperDelegate?

    func downloadContent(drumLoop: DrumLoop) {
        // loop over the files and download them if they dont exist
        drumLoop.DownloadUrls.forEach ({
            // do we have the file already if so skip it. Other wise kick off a download for it.
            let fileURL = URL(string: $0)
            let filePath = getDocumentsDirectory().appendingPathComponent(fileURL!.lastPathComponent)
            if !FileManager.default.fileExists(atPath: filePath.path ) {
                downloadFiletoDocumentsDirectory(fileURL: fileURL!, drumLoop: drumLoop)
            } else {
                if self.delegate != nil {
                    self.delegate?.DownloadComplete()
                }
            }
        })
    }

    func downloadAllContent(drumLoops: [DrumLoop]) {
        for drumLoop in drumLoops {
            downloadContent(drumLoop: drumLoop)
        }
    }

    func downloadFiletoDocumentsDirectory(fileURL: URL, drumLoop: DrumLoop) {
        let session = URLSession.shared
        let task = session.dataTask(with: fileURL, completionHandler: { data, response, error in

            if error != nil || data == nil {
                if self.delegate != nil {
                    self.delegate?.DownloadFailed()
                }
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
//                if self.delegate != nil {
//                    self.delegate?.storeKitHelperDownloadFailed()
//                }
                return
            }
            // Save to local file.
            guard let data = data else { print("Data corrupt"); return }
            let filePath = self.getDocumentsDirectory().appendingPathComponent(fileURL.lastPathComponent)
            do {
                try data.write(to: filePath)
                if self.delegate != nil {
                    self.delegate?.DownloadComplete()
                }
            } catch {
                print("Failed to write music file data to \(filePath) error: \(error.localizedDescription)")
            }
        })
        task.taskDescription = drumLoop.LoopName
        task.resume()
    }

    func haveTheFilesBeenDownloaded(drumLoop: DrumLoop) -> Bool {
        var filesDownloaded = false
        for filePath in drumLoop.Files {
            if FileManager.default.fileExists(atPath: getDocumentsDirectory().appendingPathComponent(filePath).path) {
                filesDownloaded = true
            } else {
                return false
            }
        }
        return filesDownloaded
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

extension DownloadHelper: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate{
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if delegate != nil {
            delegate?.DownloadComplete()
        }
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if delegate != nil {
            delegate?.DownloadFailed()
        }
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if delegate != nil {
            delegate?.DownloadFailed()
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if delegate != nil {
            delegate?.DownloadFailed()
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if delegate != nil {
            delegate?.DownloadComplete()
        }
    }
}
