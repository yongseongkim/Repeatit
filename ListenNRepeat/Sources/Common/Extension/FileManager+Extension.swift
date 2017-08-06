//
//  FileManager+Extension.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 6. 6..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

extension FileManager {
    func loadDirectories(url: URL) -> [File] {
        return self.loadFiles(url: url, includeFiles: false).directores
    }
    
    func loadFiles(url: URL, includeDirectories:Bool = true, includeFiles:Bool = true) -> (directores: [File], files: [File]) {
        var directories = [File]()
        var files = [File]()
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: url.path)
            
            for fileName in fileNames {
                let url = URL(fileURLWithPath: url.path.appendingFormat("/%@", fileName))
                var isDir:ObjCBool = true
                if (FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)) {
                    if (isDir.boolValue && includeDirectories) {
                        directories.append(File(url: url, isDirectory: true))
                    } else if (!isDir.boolValue && includeFiles) {
                        files.append(File(url: url))
                    }
                }
            }
        } catch let error {
            print(error)
        }
        return (directories, files)
    }
}
