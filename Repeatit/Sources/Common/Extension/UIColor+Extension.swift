//
//  UIColor+Extension.swift
//  Repeatit
//
//  Created by KimYongSeong on 2017. 4. 18..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

extension UIColor {
    static let lushLava = UIColor(argb: 0xFFFF4500)
    static let aquaMenthe = UIColor(argb: 0xFF7FFFD4)
    static let classicBlue = UIColor(argb: 0xFF0F4C81)
    static let provence = UIColor(argb: 0xFF658DC6)
    static let babyBlue = UIColor(argb: 0xFFB5C7D3)
    static let limePunch = UIColor(argb: 0xFFC0D725)

    static var systemBlack: UIColor { UIColor(named: "systemBlack")! }
    static var systemWhite: UIColor { UIColor(named: "systemWhite")! }
    static var gray30: UIColor { UIColor(argb: 0xFFF5F6F7)}
    static var gray50: UIColor { UIColor(argb: 0xFFEFEFF1)}
    static var gray100: UIColor { UIColor(argb: 0xFFD5D7DC)}
    static var gray200: UIColor { UIColor(argb: 0xFFC0C2CC)}
    static var gray300: UIColor { UIColor(argb: 0xFF9DA0AE)}
    static var gray400: UIColor { UIColor(argb: 0xFF868B9C)}
    static var gray500: UIColor { UIColor(argb: 0xFF73788B)}
    static var gray700: UIColor { UIColor(argb: 0xFF4B5064)}

    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }

    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            a: (argb >> 24) & 0xFF
        )
    }
}
