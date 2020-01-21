//
//  UIView+Extension.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/04.
//

import UIKit
import SnapKit

public extension UIView {
    func visible() {
        isHidden = false
    }

    func invisible() {
        isHidden = true
    }

    func visibleOrInvisible(_ isVisible: Bool) {
        isHidden = !isVisible
    }
}

public extension ConstraintViewDSL {
    func addSubview(_ view: UIView, _ closure: (ConstraintMaker) -> Void) {
        (self.target as? UIView)?.addSubview(view)
        view.snp.makeConstraints(closure)
    }

    func addArrangedSubview(_ view: UIView, _ closure: (ConstraintMaker) -> Void) {
        (self.target as? UIStackView)?.addArrangedSubview(view)
        view.snp.makeConstraints(closure)
    }
}

