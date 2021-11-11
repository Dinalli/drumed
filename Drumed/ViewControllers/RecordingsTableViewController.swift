//
//  RecordingsTableViewController.swift
//  Drumed
//
//  Created by Andrew Donnelly on 11/01/2020.
//  Copyright © 2020 Andrew Donnelly. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class RecordingsTableViewController: UITableViewController {

    var recordingFiles: [URL] = [URL]()

    override func viewDidLoad() {
        super.viewDidLoad()
        getFiles()
    }

    func getFiles() {
        do {
            let tempRecordingFiles = try FileManager.default.contentsOfDirectory(at: getRecordingsDirectory(), includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            recordingFiles = tempRecordingFiles.filter{ $0.pathExtension == "caf" }
            recordingFiles.sort { (fileA, fileB) -> Bool in
                do{
                    let aFileAttributes = try FileManager.default.attributesOfItem(atPath: fileA.path) as [FileAttributeKey:Any]
                    let bFileAttributes = try FileManager.default.attributesOfItem(atPath: fileB.path) as [FileAttributeKey:Any]
                    guard let aDate = aFileAttributes[FileAttributeKey.creationDate] as? Date else { return true }
                    guard let bDate = bFileAttributes[FileAttributeKey.creationDate] as? Date else { return true }
                    return aDate > bDate
                } catch let theError {
                    print("file not found \(theError)")
                }
                return true
            }
            if recordingFiles.count > 0 {
                tableView.reloadData()
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "No Recordings", message: "You have no recordings to show, try playing along and recording a loop to hear it back here.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } catch {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "No Recordings", message: "You have no recordings to show, try playing along and recording a loop to hear it back here.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recordingFiles.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell", for: indexPath) as? PlaybackTableViewCell else { return UITableViewCell() }

        // Configure the cell...
        let objectURL:URL = recordingFiles[indexPath.row]
        cell.titleLabel?.text = objectURL.lastPathComponent

        let asset = AVURLAsset(url: objectURL, options: nil)
        let audioDuration = asset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        cell.durationLabel?.text = audioDurationSeconds.formattedTimeString()

        do{
            let aFileAttributes = try FileManager.default.attributesOfItem(atPath: objectURL.path) as [FileAttributeKey:Any]
            guard let creationDate = aFileAttributes[FileAttributeKey.creationDate] as? Date else { return UITableViewCell() }
            cell.dateLabel?.text = creationDate.toString(dateFormat: "dd-MM-yyyy hh:mm:ss")
        } catch let theError {
            print("file not found \(theError)")
            cell.dateLabel?.text = "No Date"
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source

            do {
                let objectURL:URL = recordingFiles[indexPath.row]
                try FileManager.default.removeItem(at: objectURL)
                getFiles()
            } catch {
                print("Could not delete recording")
            }
        }   
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objectURL:URL = recordingFiles[indexPath.row]
        let player = AVPlayer(url: objectURL)
        let vc = AVPlayerViewController()
        vc.player = player

        present(vc, animated: true) {
            vc.player?.play()
        }
    }
}
