//
//  BuildConfig.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/19.
//

import Foundation

struct BuildConfig {
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
