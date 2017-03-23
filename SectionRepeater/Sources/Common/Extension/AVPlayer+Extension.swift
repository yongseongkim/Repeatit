//
//  AVPlayer+Extension.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 3. 23..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

extension AVPlayer {
    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}
