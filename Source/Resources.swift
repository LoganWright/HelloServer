//
//  Resources.swift
//  HelloServer
//
//  Created by Logan Wright on 2/15/16.
//  Copyright © 2016 LoganWright. All rights reserved.
//

import Foundation
import Nest
import Inquiline

public let workingDirectory = "./"
public let resourcesDirectory = "\(workingDirectory)Resources/"

public final class ResourceResponse: ResponseType {
    public let status: Status
    
    public var statusLine: String {
        return status.description
    }
    
    public var headers: [Header]
    public let body: PayloadType?
    
    public let bytes: [UInt8]
    
    public init?(status: Status, fileName: String, type: String) {
        let file = "\(resourcesDirectory)\(fileName)"
        guard let data = NSData(contentsOfFile: file) else {
            return nil
        }
        
        self.status = status
        self.headers = [("ContentType", "\(type)")]

        var bytes = [Byte](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length: bytes.count)
        self.bytes = bytes
        
        self.body = Stream(bytes)
    }
}
