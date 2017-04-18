//
//  FileDisplayManager.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 3. 12..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

class FileDisplayItem {
    var name: String
    var path: String
    var attributes: Dictionary<FileAttributeKey, Any>
    var isParentDirectory = false
    
    init(name: String, path:String, attributes: Dictionary<FileAttributeKey, Any>) {
        self.name = name
        self.path = path
        self.attributes = attributes
    }
}

protocol FileDisplayManagerDelegate {
    func didChangeCurrentPath(directories: [FileDisplayItem], files: [FileDisplayItem])
}

class FileDisplayManager {
    public var delegate: FileDisplayManagerDelegate?
    fileprivate var manager: FileManager
    fileprivate var rootPath: String
    fileprivate var currentPath: String {
        if (self.paths.count > 0) {
            return self.rootPath.appendingFormat("/%@", self.paths.joined(separator: "/"))
        }
        return self.rootPath
    }
    fileprivate var paths = [String]()
    
    init(rootPath: String) {
        self.manager = FileManager.default
        self.rootPath = rootPath
    }
    
    public func loadCurrentPathContents() {
        do {
            var directories = [FileDisplayItem]()
            var files = [FileDisplayItem]()
            
            // add path to move parent directory
            if let _ = self.paths.last {
                let parentDirectory = FileDisplayItem(name: "..", path:"", attributes: Dictionary<FileAttributeKey, Any>())
                parentDirectory.isParentDirectory = true
                directories.append(parentDirectory)
            }
            
            let fileNames = try self.manager.contentsOfDirectory(atPath: self.currentPath)
            for fileName in fileNames {
                let filePath = self.currentPath.appendingFormat("/%@", fileName)
                let attributes = try self.manager.attributesOfItem(atPath: filePath)
                var isDir:ObjCBool = true
                if (self.manager.fileExists(atPath: filePath, isDirectory: &isDir)) {
                    if (isDir.boolValue) {
                        directories.append(FileDisplayItem(name: fileName, path: filePath, attributes: attributes))
                    } else {
                        files.append(FileDisplayItem(name: fileName, path: filePath, attributes: attributes))
                    }
                }
            }
            self.delegate?.didChangeCurrentPath(directories: directories, files: files)
        } catch let error {
            print(error)
        }
    }
    
    public func createDirectory(name: String) -> Bool {
        do {
            try self.manager.createDirectory(atPath: String.init(format: "%@/%@", currentPath, name), withIntermediateDirectories: false, attributes: nil)
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    public func moveFiles(paths: [String]) {
        for path in paths {
            do {
                if self.manager.fileExists(atPath: path) {
                    let url = URL(fileURLWithPath: path)
                    try self.manager.moveItem(atPath: path, toPath: String.init(format: "%@/%@", currentPath, url.lastPathComponent))
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    public func moveToParentDirectory() {
        guard let _ = self.paths.last else {
            print("It's root directory")
            return
        }
        self.paths.removeLast()
        self.loadCurrentPathContents()
    }
    
    public func moveToDirectory(directoryName: String) {
        self.paths.append(directoryName)
        self.loadCurrentPathContents()
    }
    
    public func removeFile(item: FileDisplayItem) {
        do {
            let url = URL(fileURLWithPath: item.path)
            try self.manager.removeItem(at: url)
        } catch let error as NSError {
            print(error)
        }
    }
}
