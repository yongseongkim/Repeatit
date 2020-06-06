//
//  Player.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import Foundation
import Combine

protocol PlayItem {
    var url: URL { get }
}

protocol Player {
    // MARK: Properties
    var isPlaying: Bool { get }
    var playItem: PlayItem? { get }
    var playTimeSeconds: Double { get }
    var playTimeMillis: Int { get }
    var duration: Double { get }
    // MARK: -

    // MARK: Event
    var isPlayingPublisher: AnyPublisher<Bool, Never> { get }
    var playTimePublisher: AnyPublisher<Double, Never> { get }
    // MARK: -

    // MARK: Actions
    func togglePlay()
    func play(item: PlayItem)
    func pause()
    func resume()
    func stop()
    func move(to: Double)
    func moveForward(by seconds: Double)
    func moveBackward(by seconds: Double)
    // MARK: -
}
