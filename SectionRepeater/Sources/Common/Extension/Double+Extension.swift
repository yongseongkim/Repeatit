//
//  Double+Extension.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 16..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import Darwin

let sideValue = Darwin.pow(0.1, 2)

extension Double {
    func roundToPlace(place: Int) -> Double {
        let divisor = Darwin.pow(10.0, Double(place))
        return self.multiplied(by: divisor).rounded() / divisor
    }
    
    func leftSide() -> Double {
        return self.subtracting(sideValue)
    }
    
    func rightSide() -> Double {
        return self.adding(sideValue)
    }
}
