//
//  AppDelegate.swift
//  Repeatit
//
//  Created by KimYongSeong on 2017. 2. 5..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        if !FileManager.default.fileExists(atPath: URL.homeDirectory.path) {
            try? FileManager.default.createDirectory(at: URL.homeDirectory, withIntermediateDirectories: true)
        }

        // Sample Media File
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: URL.homeDirectory.path)
            if contents.count == 0 {
                // sample 넣기
                do {
                    if let path = Bundle.main.path(forResource: "sample", ofType: "mp3") {
                        try FileManager.default.copyItem(atPath: path, toPath: URL.homeDirectory.appendingPathComponent("sample.mp3").path)
                    }
                    let sampleYouTubeURL = URL.homeDirectory.appendingPathComponent("sample.youtube")
                    let data = try JSONEncoder().encode(YouTubeItem(id: "VuavFEzN6oA"))
                    try data.write(to: sampleYouTubeURL)
                } catch let exception {
                    print(exception)
                }
            }
        } catch let error {
            print(error)
        }

        // Report

        // View
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
