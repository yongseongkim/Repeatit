//
//  AppDelegate.swift
//  Repeatit
//
//  Created by KimYongSeong on 2017. 2. 5..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Crashlytics
import Fabric
import Firebase
import RealmSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let player = BasicAudioPlayer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !FileManager.default.fileExists(atPath: URL.homeDirectory.path) {
            try! FileManager.default.createDirectory(at: URL.homeDirectory, withIntermediateDirectories: true)
        }

        // Delete Realm files.
//        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
//        let realmURLs = [
//            realmURL,
//            realmURL.appendingPathExtension("lock"),
//            realmURL.appendingPathExtension("note"),
//            realmURL.appendingPathExtension("management")
//        ]
//        for URL in realmURLs {
//            do {
//                try FileManager.default.removeItem(at: URL)
//            } catch {
//                // handle error
//            }
//        }

        // Sample Media File
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: URL.homeDirectory.path)
            if contents.count == 0 {
                // sample 노래 넣기
                if let path = Bundle.main.path(forResource: "sample", ofType: "mp3") {
                    try FileManager.default.copyItem(atPath: path, toPath: URL.homeDirectory.appendingPathComponent("sample.mp3").path)
                }
            }
        } catch let error {
            print(error)
        }

        // Report
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])

        // View
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        Logger.loggingPlayerControlTap()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        Logger.loggingPlayerControlTap()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("application open")
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

