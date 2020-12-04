//
//  View+Extension.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/12.
//

import SwiftUI

extension View {
    @ViewBuilder func visibleOrInvisible(_ isVisible: Bool) -> some View {
        if isVisible {
            self
        } else {
            self.hidden()
        }
    }

    @ViewBuilder func visibleOrGone(_ isVisible: Bool) -> some View {
        if isVisible {
            self
        }
    }
}
