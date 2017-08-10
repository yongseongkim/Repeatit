//
//  AppDelegate.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 2. 5..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    public class func currentAppDelegate() -> AppDelegate? {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            return delegate
        }
        return nil
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // UI
        self.window = UIWindow(frame: CGRect(x: 0, y: 0, width: UIScreen.mainWidth, height: UIScreen.mainHeight))
        self.window?.rootViewController = RootViewController()
        self.window?.makeKeyAndVisible()
        UINavigationBar.appearance().tintColor = UIColor.black
        
        // Realm
        let defaultRealmURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
//        do {
//            let contents = try FileManager.default.contentsOfDirectory(atPath: defaultRealmURL.path)
//            for content in contents {
//                try FileManager.default.removeItem(at: defaultRealmURL.appendingPathComponent(content))
//            }
//        } catch _ { }
        var config = Realm.Configuration()
        config.fileURL = defaultRealmURL.appendingPathComponent("ListenNRepeat.realm")
        Realm.Configuration.defaultConfiguration = config
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: URL.documentsURL.path)
            if contents.count == 0 {
                // sample 노래 넣기
                if let path = Bundle.main.path(forResource: "sample", ofType: "mp3") {
                    try FileManager.default.copyItem(atPath: path, toPath: URL.documentsURL.appendingPathComponent("sample.mp3").path)
                }
            }
        } catch let error {
            print(error)
        }
        
        // Report
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("application open")
        return true
    }
}

