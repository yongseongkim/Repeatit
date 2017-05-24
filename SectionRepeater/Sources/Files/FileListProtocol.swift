//
//  FileListProtocol.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 5. 22..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

protocol LoadFilesProtocol {
    func loadOnlyDirectories(url: URL)
    func loadFiles(url: URL)
    func didLoadFiles(directories: [File], files: [File])
}

extension LoadFilesProtocol {
    func loadOnlyDirectories(url: URL) {
        self.internalLoad(path: url.path, includeDirectories: true, includeFiles: false)
    }
    
    func loadFiles(url: URL) {
        self.internalLoad(path: url.path)
    }
    
    private func internalLoad(path: String, includeDirectories:Bool = true, includeFiles:Bool = true) {
        var directories = [File]()
        var files = [File]()
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: path)
            
            for fileName in fileNames {
                let url = URL(fileURLWithPath: path.appendingFormat("/%@", fileName))
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
        self.didLoadFiles(directories: directories, files: files)
    }
}
