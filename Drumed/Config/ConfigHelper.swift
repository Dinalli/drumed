//
//  ConfigHelper.swift
//  Drumed
//
//  Created by Andrew Donnelly on 25/08/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit

struct DrumLoop: Codable {
    let Section: String
    let LoopName: String
    let BPM: String
    let Icon: String
    let CustomIconUrl: String
    var SubscriptionRequired: Bool
    let DownloadUrls: [String]
    let Files: [String]
    private enum CodingKeys: String, CodingKey {
        case Section
        case LoopName
        case BPM
        case Icon
        case CustomIconUrl
        case SubscriptionRequired
        case DownloadUrls
        case Files
    }
}

class ConfigHelper: NSObject {

    var loopsArray = [DrumLoop]()

    func getSections() -> [String] {
        let sections = loopsArray.compactMap({ $0.Section }) as [String]
        return sections.removingDuplicates()
    }

    func getForSection(sectionName: String) -> [DrumLoop] {
        let loops = loopsArray.filter( {$0.Section == sectionName}) as [DrumLoop]
        return loops
    }

    func getLockedLoops() -> [DrumLoop] {
        let loops = loopsArray.filter( {$0.SubscriptionRequired}) as [DrumLoop]
        return loops
    }

    func getLatestConfig() {
        if let lastConfigDate = defaultsHelper.getDefault(for: "LastConfigDate") as? Date {
            // do we have a date in user settings
            // Anything over 7 days we check.
            if lastConfigDate < Date().addingTimeInterval(-86400)  {
                 getConfigFromAWS()
            } else {
                getSavedJSONFile()
            }
        } else {
            getConfigFromAWS()
        }
    }


    func getConfigFromFile() {
        print("GET BUNDLE FILE")
        if let filepath = Bundle.main.path(forResource: "Drumed", ofType: "json") {
            do {
                guard let data = try? Data(contentsOf: URL(fileURLWithPath: filepath)) else { return }
                let decoder = JSONDecoder()
                loopsArray = try decoder.decode([DrumLoop].self, from: data)
                print("GOT BUNDLE FILE")
            } catch {
                // contents could not be loaded
                print("JSON Conversion error")
            }
        } else {
            // example.txt not found!
            print("file not found")
        }
    }

    func getConfigFromAWS() {
        let session = URLSession.shared
        let url = URL(string: "https://drumed-deployments-mobilehub-1294664040.s3-eu-west-1.amazonaws.com/Drumed.json")!
        let task = session.dataTask(with: url, completionHandler: { data, response, error in

            print("GET AWS FILE")
            if error != nil || data == nil {
                self.getConfigFromFile()
                return
            }

            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                self.getConfigFromFile()
                return
            }

            guard let mime = response.mimeType, mime == "application/json" else {
                self.getConfigFromFile()
                return
            }

            do {
                let decoder = JSONDecoder()
                self.loopsArray = try decoder.decode([DrumLoop].self, from: data!)
                print(self.loopsArray)
                // Save to local file.
                self.saveNewJSONtoLocalFile(data: data)
                defaultsHelper.setDefault(for: "LastConfigDate", with: Date())
                print("GOT AWS FILE SEND NOTIFICATION")
                NotificationCenter.default.post(Notification(name: Notification.Name("kUpdateLoops"), object: nil, userInfo: nil))
            } catch {
                print("JSON error: \(error)")
                self.getConfigFromFile()
            }
        })
        task.resume()
    }

    func getSavedJSONFile() {
        print("GET SAVED FILE")
        let filePath = getDocumentsDirectory().appendingPathComponent("Drumed.json")
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath.path)) else { return }
                let decoder = JSONDecoder()
                loopsArray = try decoder.decode([DrumLoop].self, from: data)
                print("GOT SAVED FILE")
            } catch {
                // contents could not be loaded
                print("JSON Conversion error")
            }
        }
    }

    func saveNewJSONtoLocalFile(data: Data?) {
        guard let data = data else { return }
        let filePath = getDocumentsDirectory().appendingPathComponent("Drumed.json")
        do {
            try data.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    /// Converts data to JSON format, returns nil if not valid
    func getJsonFromData(data: Data) -> Any! {
        do {
            let json = try JSONSerialization.jsonObject(with: data,
                                                        options: JSONSerialization.ReadingOptions.allowFragments)
            return json
        } catch {
            return nil
        }
    }
}
