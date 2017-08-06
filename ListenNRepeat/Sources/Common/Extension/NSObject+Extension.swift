//
//  NSObject+Extension.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 2. 19..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

extension NSObject {
    class func className() -> String {
        return String(describing: self)
    }
}
