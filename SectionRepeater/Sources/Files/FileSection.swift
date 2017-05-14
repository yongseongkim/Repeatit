//
//  FileSection.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 5. 14..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import RxDataSources


struct FileSection {
    var items: [Item]
}

extension FileSection: SectionModelType {
    typealias Item = File
    
    init(original: FileSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(items: [Item]?) {
        self.items = items ?? [Item]()
    }
}
