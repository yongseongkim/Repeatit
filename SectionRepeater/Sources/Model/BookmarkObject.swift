//
//  BookmarkDB.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 3. 19..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import RealmSwift

class BookmarkObject: Object {
    dynamic var path = ""
    let times = List<DoubleObject>()
    
    convenience init(path: String) {
        self.init()
        self.path = path
    }
    
    override static func primaryKey() -> String? {
        return "path"
    }
}
