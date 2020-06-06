//
//  List+Extension.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import Foundation

extension Array where Element == Bookmark {
    mutating func insertionSort(with element: Element) {
        var idx = 0
        while true {
            if idx == self.count || self[idx].startMillis > element.startMillis {
                break
            }
            idx += 1
        }
        self.insert(element, at: idx)
    }
}
