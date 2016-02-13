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

// MARK: Request Extensions

extension Request: CustomStringConvertible {
    public var jsonBody: Json? {
        return try? Json.deserialize(body)
    }
    
    public var description: String {
        var string = "\n"
        
        string += "\nMethod    : \(method)"
        string += "\nData      : \(data)"
        string += "\nCookies   : \(cookies)"
        string += "\nPath      : \(path)"
        string += "\nHeaders   : \(headers)"
        string += "\nBody      : \(jsonBody)"
        string += "\nAddress   : \(address)"
        string += "\nParameters: \(parameters)"
        string += "\nSession   : \(session)"
        
        return string + "\n"
    }
}

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
            .transformToNode { $0.timeIntervalSince1970 }
    }
}

var messages: [Message] = []

Route.post("messages") { request in
    let js = try Json.deserialize(request.body)
    let message = try Message(data: js)
    let serialized = try message
        .jsonRepresentation()
        .serialize(.PrettyPrint)
    messages.append(message)
    return serialized
}

Route.get("messages") { _ in
    let messagesString = try messages
        .jsonRepresentation()
        .serialize(.PrettyPrint)
    return Response(status: .OK, text: messagesString)
}

Route.get("hello") { _ in
    return ["Hello" : "World"]
}

Route.get("hello/:name") { request in
    let name = request.parameters["name"] ?? "World"
    return ["Hello" : name]
}

let server = Server()
server.run(port: 8080)
