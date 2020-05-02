//
//  SwiftEntryKit+Extension.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/08.
//

import SwiftEntryKit
import SwiftUI

extension SwiftEntryKit {
    public class func display<Content: View>(@ViewBuilder builder: @escaping () -> Content, using attributes: EKAttributes) {
        let view = UIHostingController(rootView: builder()).view!
        view.backgroundColor = UIColor.clear
        DispatchQueue.main.async {
            SwiftEntryKit.display(entry: view, using: attributes)
        }
    }
}
