//
//  UpdateManager.swift
//  Tick
//
//  Created by Pavel Neizhmak on 06/01/2025.
//

import Foundation

class UpdateManager {
    static let shared = UpdateManager()
    private let ignoredVersionKey = "IgnoredVersion"

    private init() {}

    func checkForUpdates(completion: @escaping (Bool, String?, String?) -> Void) {
        guard let url = URL(string: "https://raw.githubusercontent.com/PNeizhmak/Tick/refs/heads/main/Build/version.json") else {
            print("Invalid URL")
            completion(false, nil, nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch update info: \(error.localizedDescription)")
                completion(false, nil, nil)
                return
            }

            guard let data = data else {
                print("No data received from server")
                completion(false, nil, nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let latestVersion = json["latest_version"],
                   let downloadURL = json["download_url"] {

                    let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
                    let ignoredVersion = UserDefaults.standard.string(forKey: self.ignoredVersionKey)

                    if currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending &&
                        latestVersion != ignoredVersion {
                        completion(true, latestVersion, downloadURL)
                    } else {
                        completion(false, nil, nil)
                    }
                } else {
                    print("Invalid JSON format")
                    completion(false, nil, nil)
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
                completion(false, nil, nil)
            }
        }

        task.resume()
    }

    func ignoreUpdate(version: String) {
        UserDefaults.standard.set(version, forKey: ignoredVersionKey)
    }
}
