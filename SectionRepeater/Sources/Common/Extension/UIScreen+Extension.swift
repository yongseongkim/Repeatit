//
//  UIScreen+Extension.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 1..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

extension UIScreen {
    class func mainScreenSize() -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    class func mainScreenWidth() -> CGFloat {
        return UIScreen.mainScreenSize().width
    }
    
    class func mainScreenHeight() -> CGFloat {
        return UIScreen.mainScreenSize().height
    }
}
