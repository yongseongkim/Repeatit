//
//  Datastore.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/18.
//

import Foundation
import GRDB

class Datastore {
    static let shared: Datastore = Datastore()

    var dbQueue: DatabaseQueue? {
        return try? DatabaseQueue(path: URL.databaseURL.path)
    }

    func configure() {
        guard let dbQueue = try? DatabaseQueue(path: URL.databaseURL.path) else { return }
        try? DictationNote.configure(dbQueue: dbQueue)
    }
}
