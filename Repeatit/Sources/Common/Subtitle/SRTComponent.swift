//
//  SRTComponent.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/08/25.
//

import Foundation

struct SRTComponent {
    let startMillis: Int
    let endMillis: Int
    let caption: String

    func update(
        startMillis: Int? = nil,
        endMillis: Int? = nil,
        caption: String? = nil
    ) -> SRTComponent {
        return SRTComponent(
            startMillis: startMillis ?? self.startMillis,
            endMillis: endMillis ?? self.endMillis,
            caption: caption ?? self.caption
        )
    }
}
