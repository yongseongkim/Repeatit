//
//  SceneDelegate.swift
//  SwiftUIExercise
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 YongSeong Kim. All rights reserved.
//

import Combine
import UIKit
import SwiftUI

enum SceneState {
    case willConnectTo(session: UISceneSession)
    case willEnterForeground
    case willResignActive
    case didBecomeActive
    case didDisconnect
    case didEnterBackground
    case didOpenURLContexts(contexts: Set<UIOpenURLContext>)
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let sceneStateSubject = PassthroughSubject<SceneState, Never>()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("willConnectTo")
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
//            window.rootViewController = UIHostingController(
//                rootView: AppView()
//                    .environment(\.appComponent, AppComponent(sceneStateSubject: sceneStateSubject))
//            )
            window.rootViewController = UIHostingController(
                rootView: Text("test").background(Color.red)
            )
            self.window = window
            window.makeKeyAndVisible()
        }
        UINavigationBar.appearance().tintColor = .systemBlack
        sceneStateSubject.send(.willConnectTo(session: session))
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        sceneStateSubject.send(.didDisconnect)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        sceneStateSubject.send(.didBecomeActive)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        sceneStateSubject.send(.willResignActive)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        sceneStateSubject.send(.willEnterForeground)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        sceneStateSubject.send(.didEnterBackground)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            let fromURL = urlContext.url
            if fromURL.isFileURL {
                let toURL = URL.homeDirectory.appendingPathComponent(fromURL.lastPathComponent)
                try? FileManager.default.copyItem(at: fromURL, to: toURL)
            }
        }
        sceneStateSubject.send(.didOpenURLContexts(contexts: URLContexts))
    }
}
