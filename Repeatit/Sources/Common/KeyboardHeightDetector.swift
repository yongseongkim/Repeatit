//
//  KeyboardHeightDetector.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/03/17.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct KeyboardHeightDetector: ViewModifier {
    @Binding var height: CGFloat

    init() {
        self._height = .constant(0)
    }

    init(_ height: Binding<CGFloat>) {
        self._height = height
    }

    func body(content: Content) -> some View {
        content
            .padding(.bottom, height)
            .edgesIgnoringSafeArea(height == 0 ? Edge.Set() : .bottom)
            .onAppear(perform: subscribeToKeyboardEvents)
    }

    private let keyboardWillOpen = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
        .map { $0.height }

    private let keyboardWillHide =  NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat(0) }

    private func subscribeToKeyboardEvents() {
        _ = keyboardWillOpen.merge(with: keyboardWillHide)
            .subscribe(on: RunLoop.main)
            .assign(to: \.height, on: self)
    }
}
