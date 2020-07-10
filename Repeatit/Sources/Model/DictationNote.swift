//
//  DictationNote.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/18.
//

import Foundation
import RealmSwift

class DictationNote: Object {
    @objc dynamic var relativePath: String = ""
    @objc dynamic var note: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    override static func primaryKey() -> String? {
        return "relativePath"
    }

    static func keyPath(url: URL) -> String {
        guard let relativePath = url.path.components(separatedBy: URL.homeDirectory.path).last else { return url.path }
        return relativePath
    }
}
