//
//  UIApplication+Extension.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/18.
//

import UIKit

extension UIApplication {
    static func hideKeyboard() {
        shared.windows
            .filter { $0.isKeyWindow }
            .forEach { $0.endEditing(true) }
    }
}
