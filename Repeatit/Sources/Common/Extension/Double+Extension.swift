//
//  Double+Extension.swift
//  Repeatit
//
//  Created by KimYongSeong on 2017. 4. 16..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

extension Double {
    static let sideValue = pow(Double(0.1), Double(2))
    
    func roundTo(place: Int) -> Double {
        let divisor = pow(10, Double(place))
        return (self * divisor.rounded()) / divisor
    }

    func leftSide() -> Double {
        return self - .sideValue
    }
    
    func rightSide() -> Double {
        return self + .sideValue
    }
}
