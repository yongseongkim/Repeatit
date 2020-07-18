//
//  AppComponent.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/13.
//

import Combine
import Foundation
import SwiftUI

struct AppComponentEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppComponent = AppComponent(sceneStateSubject: PassthroughSubject<SceneState, Never>())
}

extension EnvironmentValues {
    var appComponent: AppComponent {
        get {
            return self[AppComponentEnvironmentKey.self]
        }
        set {
            self[AppComponentEnvironmentKey.self] = newValue
        }
    }
}

class AppComponent {
    private let sceneStateSubject: PassthroughSubject<SceneState, Never>
    let mediaPlayer = MediaPlayer()

    init(sceneStateSubject: PassthroughSubject<SceneState, Never> = PassthroughSubject()) {
        self.sceneStateSubject = sceneStateSubject
    }

    var sceneStatePublisher: AnyPublisher<SceneState, Never> {
        return sceneStateSubject.eraseToAnyPublisher()
    }
}
