//
//  AppDelegate.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 5..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import Fabric
import Crashlytics

extension Notification.Name {
    static let onEnterForeground = Notification.Name("appdelegate.enterforeground")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public let notificationCenter = NotificationCenter()
    
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
        config.fileURL = defaultRealmURL.appendingPathComponent("sectionRepeater.realm")
        Realm.Configuration.defaultConfiguration = config
        
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
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        self.notificationCenter.post(name: .onEnterForeground, object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("application open")
        return true
    }
}

