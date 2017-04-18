//
//  Double+Extension.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 16..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

let sideValue = 1 * pow(0.1, 10)

extension Double {
    func leftSide() -> Double {
        return self.subtracting(sideValue)
    }
    
    func rightSide() -> Double {
        return self.adding(sideValue)
    }
}
