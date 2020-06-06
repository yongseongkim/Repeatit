//
//  URL+Extension.swift
//  Repeatit
//
//  Created by KimYongSeong on 2017. 5. 28..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

extension URL {
    static let documentsURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    static let homeDirectory = URL.documentsURL.appendingPathComponent("Home")

    static func relativePathFromHome(url: URL) -> String {
        guard let relativePath = url.path.components(separatedBy: URL.homeDirectory.path).last else { return url.path }
        return relativePath
    }

    func bookmarkKey() -> String {
        guard let relativePath = self.path.components(separatedBy: URL.homeDirectory.path).last else { return self.path }
        return relativePath
    }
}
