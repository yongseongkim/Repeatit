//
//  PlayerControlClient.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import Foundation

protocol PlayerControlClient {
    var resume: (URL) -> Void { get }
    var pause: (URL) -> Void { get }
    var move: (URL, Seconds) -> Void { get }
}
