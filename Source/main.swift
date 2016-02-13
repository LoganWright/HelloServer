//
//  main.swift
//  HelloServer
//
//  Created by Logan Wright on 2/12/16.
//  Copyright © 2016 LoganWright. All rights reserved.
//

import Foundation
import Vapor
import PureJsonSerializer
import Genome


struct Message: MappableObject {
    let id: String
    let message: String
    let timestamp: NSDate
    
    init(msg: String) {
        id = NSUUID().UUIDString
        message = msg
        timestamp = NSDate()
    }
    
    init(map: Map) throws {
        id = NSUUID().UUIDString
        message = try map.extract("message")
        timestamp = NSDate()
    }
    
    func sequence(map: Map) throws {
        try id ~> map["id"]
        try message ~> map["message"]
        try timestamp ~> map["timestamp"]
            .transformToNode { date in
                return date.timeIntervalSince1970
        }
    }
}

Route.post("messages") { request in
    let js = try Json.deserialize(request.body)
    print("Got js: \(js)")
    let message = try Message(data: js)
    print("Got msg: \(message)")
    let serialized = try message.jsonRepresentation().serialize()
    print("Serialized: \(serialized)")
    return serialized
}

Route.get("messages") { _ in
    let string = try [
        "hi",
        "there",
        "another",
        "Thing"
        ]
        .map(Message.init)
        .jsonRepresentation()
        .serialize(.PrettyPrint)
    
    return Response(status: .OK, text: string)
}

Route.get("complex") { request in
    print("Making request: \(request)")
    let json: Json = [
        "root" : [
            ["hello" : "world"],
            ["hello" : "mars"]
        ]
    ]
    print("Sending Json: \(json)")
    return Response(status: .OK, text: json.serialize())
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
        "array",
        "sup"
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
