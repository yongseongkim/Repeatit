//
//  SceneDelegate.swift
//  SwiftUIExercise
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 YongSeong Kim. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let rootStore = RootStore()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: RootView().environmentObject(rootStore))
            self.window = window
            window.makeKeyAndVisible()
        }
        UINavigationBar.appearance().tintColor = .systemBlack
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        rootStore.sceneDidBecomeActive()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        rootStore.sceneWillResignActive()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        rootStore.sceneWillEnterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        rootStore.sceneDidEnterBackground()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        rootStore.sceneDidOpenURLContexts(URLContexts)
    }
}
