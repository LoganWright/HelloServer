//
//  main.swift
//  HelloServer
//
//  Created by Logan Wright on 2/12/16.
//  Copyright © 2016 LoganWright. All rights reserved.
//

import Foundation
import Vapor

protocol JsonSerializable {
    
}

class JSONSerializer {
    
    class func serialize(object: Any) -> String {
        
        if let dict = object as? [String: Any] {
            var s = "{"
            var i = 0
            
            for (key, val) in dict {
                s += "\"\(key)\":\(self.serialize(val))"
                if i != (dict.count - 1) {
                    s += ","
                }
                i += 1
            }
            
            return s + "}"
        } else if let dict = object as? [String: String] {
            var s = "{"
            var i = 0
            
            for (key, val) in dict {
                s += "\"\(key)\":\(self.serialize(val))"
                if i != (dict.count - 1) {
                    s += ","
                }
                i += 1
            }
            
            return s + "}"
        } else if let arr = object as? [Any] {
            var s = "["
            
            for i in 0 ..< arr.count {
                s += self.serialize(arr[i])
                
                if i != (arr.count - 1) {
                    s += ","
                }
            }
            
            return s + "]"
        } else if let arr = object as? [String] {
            var s = "["
            
            for i in 0 ..< arr.count {
                s += self.serialize(arr[i])
                
                if i != (arr.count - 1) {
                    s += ","
                }
            }
            
            return s + "]"
        } else if let arr = object as? [Int] {
            var s = "["
            
            for i in 0 ..< arr.count {
                s += self.serialize(arr[i])
                
                if i != (arr.count - 1) {
                    s += ","
                }
            }
            
            return s + "]"
        } else if let string = object as? String {
            return "\"\(string)\""
        } else if let number = object as? Int {
            return "\(number)"
        } else {
            print(object)
            print(Mirror(reflecting: object))
            return "\"\""
        }
        
    }
}

Route.get("complex") { request in
    print("Making request: \(request)")
    let json: [String : Any] = [
        "root" : [
            ["hello" : "world"],
            ["hello" : "mars"]
        ]
    ]
    print("Sending Json: \(json)")
    return try Response(status: .OK, json: json)
}

Route.get("local-array") { _ in
    let thing: [String : [String : Any]] = [
        "one" : [
            "hi" : "there"
        ],
        "two" : [
            "hi" : "again",
            "bye" : "sup"
        ]
    ]
    
    return thing
}

Route.get("hello") { request in
    return ["Hello" : "World"]
}

Route.get("test") { request in
    print("Request: \(request)")
    let json = [
        "hello",
        "array"
    ]
    return try Response(status: .OK, json: json)
}

Route.post("test") { request in
    print("Request: \(request)")
    let json = [
        "hello",
        "array"
    ]
    return try Response(status: .OK, json: json)
}

extension Request: CustomStringConvertible {
    public var description: String {
        var string = "\n"
        
        string += "\nMethod    : \(method)"
        string += "\nData      : \(data)"
        string += "\nCookies   : \(cookies)"
        string += "\nPath      : \(path)"
        string += "\nHeaders   : \(headers)"
        var bytes = body
        let jsonData = NSData(bytes: &bytes, length: bytes.count)
        let js = try? NSJSONSerialization
            .JSONObjectWithData(jsonData, options: .AllowFragments)
        string += "\nBody      : \(js)"
        string += "\nAddress   : \(address)"
        string += "\nParameters: \(parameters)"
        string += "\nSession   : \(session)"
        
        return string + "\n"
    }
}

let server = Server()
server.run(port: 8080)
