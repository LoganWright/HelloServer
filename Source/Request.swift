//
//  Request.swift
//  HelloServer
//
//  Created by Logan Wright on 2/15/16.
//  Copyright © 2016 LoganWright. All rights reserved.
//

import Curassow
import Inquiline
import Nest
import Foundation

public typealias Byte = Int8

public final class Request: RequestType {
    public let method: String
    public let path: String
    public let headers: [Nest.Header]
    public let body: PayloadType?
    
    public internal(set) var arguments: [String : String] = [:]
    
    public let bytes: [Byte]
    
    internal init(method: String,
         path: String,
         headers: [Nest.Header],
         body: [Byte]?) {
        self.method = method
        self.path = path
        self.headers = headers
        let bytes = body ?? []
        self.bytes = bytes
        self.body = BytesPayload(bytes: bytes)
    }
    
    internal init(request: RequestType) {
        method = request.method
        path = request.path
        headers = request.headers
        
        var collection: [Byte] = []
        var mutable = request.body
        while let next = mutable?.next() {
            collection.append(next)
        }
        
        bytes = collection
        body = BytesPayload(bytes: collection)
    }
}

extension Request: CustomStringConvertible {
    
//    public var pathComponents: [String] {
//        return path.characters.split { $0 == "/" } .map { String($0) }
//    }
    
    public var description: String {
        var description = "Request:"
        description += "\n Method:"
        description += "\n  \(method): \(path)"
        
        let headerStr = headers.map { "  \($0.0) : \($0.1)" } .joinWithSeparator("\n")
        description += "\n Headers:\n\(headerStr)"
        
        let argsStr = arguments.map { "  \($0.0) : \($0.1)" } .joinWithSeparator("\n")
        description += "\n Arguments:\n\(argsStr)"
        
        if let json = json {
            description += "\n Body: \(json.serialize(.PrettyPrint))"
        } else if !bytes.isEmpty {
            var mutable = bytes
            let data = NSData(bytes: &mutable, length: mutable.count)
            let str = String(data: data, encoding: NSUTF8StringEncoding)
            description += "\n Body:\n    \(str)"
        }
        
        return description
    }
}

// TODO: Json Stuff in Another File?

import PureJsonSerializer

extension Request {
    public var json: Json? {
        guard !bytes.isEmpty else { return nil }
        return try? Json.deserialize(bytes.map { UInt8($0) })
    }
}
