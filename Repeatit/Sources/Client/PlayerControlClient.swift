//
//  PlayerControlClient.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import Foundation

protocol PlayerControlClient {
    var resume: (AnyHashable) -> Void { get }
    var pause: (AnyHashable) -> Void { get }
    var move: (AnyHashable, Seconds) -> Void { get }
}

struct MockPlayerControlClient: PlayerControlClient {
    let resume: (AnyHashable) -> Void = { _ in }
    let pause: (AnyHashable) -> Void = { _ in }
    let move: (AnyHashable, Seconds) -> Void = { _, _ in }
}
