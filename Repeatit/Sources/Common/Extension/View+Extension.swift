//
//  View+Extension.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/12.
//

import SwiftUI

extension View {
    @ViewBuilder func visible(_ isVisible: Bool) -> some View {
        if isVisible {
            self
        } else {
            self.hidden()
        }
    }
}
