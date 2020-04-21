//
//  DictationNote.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/18.
//

import GRDB

struct DictationNote: Codable, FetchableRecord, PersistableRecord {
    // based on the directory 'Docuements'
    var relativePath: String
    var note: String
    var createdAt: Date
    var updatedAt: Date

    static func configure(dbQueue: DatabaseQueue) throws {
        try dbQueue.write { db in
            try db.create(table: "dictationNote") { t in
                t.column("relativePath", .text).primaryKey().unique()
                t.column("note", .text)
                t.column("createdAt", .date)
                t.column("updatedAt", .date)
            }
        }
    }

    static func keyPath(url: URL) -> String {
        guard let relativePath = url.path.components(separatedBy: URL.documentsURL.path).last else { return url.path }
        return relativePath
    }
}
