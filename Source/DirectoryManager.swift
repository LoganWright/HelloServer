//
//  DirectoryManager.swift
//  bmap
//
//  Created by Logan Wright on 12/2/15.
//  Copyright © 2015 Intrepid. All rights reserved.
//

import Foundation

typealias Block = Void -> Void

public protocol Writeable {
    func writeToFile(file: String, atomically: Bool) -> Bool
    static func fromFile(file: String) -> Self?
}

extension String: Writeable {
    public func writeToFile(file: String, atomically: Bool) -> Bool {
        do {
            try writeToFile(file, atomically: atomically, encoding: NSUTF8StringEncoding)
            return true
        } catch {
            print("Error writing string to file: \(error)")
            return false
        }
    }
    
    public static func fromFile(file: String) -> String? {
        return try? String(contentsOfFile: file)
    }

}

extension DirectoryManager {
    var url: NSURL {
        return directoryUrl
    }
}

public final class DirectoryManager {
    
    enum Error : ErrorType {
        case UnableToCreatePath(url: NSURL)
    }
    
    private let directoryName: String
    private let fileManager: NSFileManager
    private let directoryUrl: NSURL
    
    // MARK: All Files
    
    public var allFilesInDirectory: [String] {
        guard let path = directoryUrl.path else { return [] }
        let all = try? fileManager.subpathsOfDirectoryAtPath(path)
        return all ?? []
    }
    
    // MARK: Initializer
    
    public init(directoryName: String, fileManager: NSFileManager = NSFileManager.defaultManager()) {
        self.directoryName = directoryName
        self.fileManager = fileManager
        // Should fail if not available
        self.directoryUrl = try! fileManager.directoryPathWithName(directoryName)
    }
    
    // MARK: Move
    
    public func moveFileIntoDirectory(originUrl originUrl: NSURL, targetName: String) throws {
        let filePath = directoryUrl.URLByAppendingPathComponent(targetName)
        guard let originPath = originUrl.path, targetPath = filePath.path else { return }
        if fileManager.fileExistsAtPath(targetPath) {
            try deleteFileWithName(targetName)
        }
        try fileManager.moveItemAtPath(originPath, toPath: targetPath)
    }
    
    // MARK: Write
    
    public func writeData(data: Writeable, withName name: String = NSUUID().UUIDString) -> Bool {
        let filePath = directoryUrl.URLByAppendingPathComponent(name)
        guard let path = filePath.path else { return false }
        return data.writeToFile(path, atomically: true)
    }
    
    // MARK: Delete
    
    public func deleteFileWithName(fileName: String) throws {
        let fileUrl = directoryUrl.URLByAppendingPathComponent(fileName)
        guard let path = fileUrl.path else {
            throw Error.UnableToCreatePath(url: fileUrl)
        }
        try fileManager.removeItemAtPath(path)
    }
    
    // MARK: Fetch
    
    public func fetchFileWithName<T: Writeable>(fileName: String) -> T? {
        let filePath = directoryUrl.URLByAppendingPathComponent(fileName)
        guard let path = filePath.path else { return nil }
        return T.fromFile(path)
    }
}

extension NSFileManager {
    
    private func directoryPathWithName(directoryName: String) throws -> NSURL {
        let currentDirectory = NSFileManager.defaultManager().currentDirectoryPath
        guard
            let documentsDirectoryPath = NSURL(string: currentDirectory)
            else { fatalError("Unable to create directory") }
        let directoryPath = documentsDirectoryPath.URLByAppendingPathComponent(directoryName)
        try createDirectoryIfNecessary(directoryPath)
        return directoryPath
    }
    
//    private func directoryPathWithName(directoryName: String) throws -> NSURL {
//        let pathsArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        guard
//            let pathString = pathsArray.first,
//            let documentsDirectoryPath = NSURL(string: pathString)
//            else { fatalError("Unable to create directory") }
//        let directoryPath = documentsDirectoryPath.URLByAppendingPathComponent(directoryName)
//        try createDirectoryIfNecessary(directoryPath)
//        return directoryPath
//    }
    
    private func createDirectoryIfNecessary(directoryPath: NSURL) throws {
        guard let path = directoryPath.path else { throw DirectoryManager.Error.UnableToCreatePath(url: directoryPath) }
        guard !fileExistsAtPath(path) else { return }
        try createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
    }
}