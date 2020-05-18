//
//  URL+Extension.swift
//  Repeatit
//
//  Created by KimYongSeong on 2017. 5. 28..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

extension URL {
    static let supportedFormats = ["aac", "adts", "ac3", "aif", "aiff", "aifc", "caf", "mp3", "mp4", "m4a", "snd", "au", "sd2", "wav"]
    static let documentsURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    static let homeDirectory = URL.documentsURL.appendingPathComponent("Home")

    static func relativePathFromHome(url: URL) -> String {
        guard let relativePath = url.path.components(separatedBy: URL.homeDirectory.path).last else { return url.path }
        return relativePath
    }
    
    func isPlayerSupported() -> Bool {
        if (URL.supportedFormats.contains(self.pathExtension)) {
            return true
        }
        return false
    }
    
    func bookmarkKey() -> String {
        guard let relativePath = self.path.components(separatedBy: URL.homeDirectory.path).last else { return self.path }
        return relativePath
    }
}
