//
//  CGPoint+Extension.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/03/02.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import UIKit

extension CGPoint {
    func update(x: CGFloat? = nil, y: CGFloat? = nil) -> CGPoint {
        return CGPoint(x: x ?? self.x, y: y ?? self.y)
    }

    func update(x: Double? = nil, y: Double? = nil) -> CGPoint {
        return CGPoint(x: x ?? Double(self.x), y: y ?? Double(self.y))
    }

    func update(x: Int? = nil, y: Int? = nil) -> CGPoint {
        return CGPoint(x: x == nil ? self.x : CGFloat(x!), y: x == nil ? self.y : CGFloat(y!))
    }
}
