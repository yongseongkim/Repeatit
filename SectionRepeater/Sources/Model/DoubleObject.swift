//
//  DoubleObject.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 3. 26..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import RealmSwift

class DoubleObject: Object {
    dynamic var value:Double = 0.0
    
    convenience init(doubleValue: Double) {
        self.init()
        self.value = doubleValue
    }
}
