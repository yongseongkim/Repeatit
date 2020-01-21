//
//  NSObject+Extension.swift
//  Repeatit
//
//  Created by KimYongSeong on 2017. 2. 19..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

protocol KotlinCompatible {}

extension KotlinCompatible {
    func apply(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }

    func `let`<R>(_ block: (Self) throws -> R) rethrows -> R {
        return try block(self)
    }
}

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}

extension NSObject: KotlinCompatible {}
