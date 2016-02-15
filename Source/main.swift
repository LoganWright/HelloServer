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

Route.get("test") { req in
    return Response(status: .OK, text: "\(req)")
}

Route.get("async") { request in
    return AsyncResponse() { socket in
        try socket.writeUTF8("HTTP/1.1 200 OK\r\n")
        try socket.writeUTF8("Content-Type: application/json\r\n\r\n")
        try socket.writeUTF8("{\"hello\": \"world\"}")
        try socket.writeUTF8("{\"goodbye\": \"moon\"}")
        for i in 1...10000 {
            try socket.writeUTF8("*")
        }
        socket.release()
    }
}

Route.get("welcome") { _ in
    return try View(path: "index.html")
}

Route.get("/") { request in
    let json: Json = [
        "Hello" : "Server Side Swift",
        "Featured Libraries" : [
            "Genome" : "https://github.com/loganwright/genome",
            "PureJsonSerializer" : "https://github.com/gfx/Swift-PureJsonSerializer",
            "Vapor" : "https://github.com/tannernelson/vapor"
        ],
        "BuildPack" : "https://github.com/kylef/heroku-buildpack-swift",
        "Hosted On" : "Heroku"
    ]
    
    let resp = json.serialize(.PrettyPrint)
    return Response(status: .OK, text: resp)
}

class MyMiddleware: Middleware {
    func handle(handler: Request -> Response) -> (Request -> Response) {
        return { request in
            print("Incoming request from \(request)")
            
            let response = handler(request)
            
            print("Responding with status \(response)")
            
            return response
        }
    }
}

let server = Server()
server.middleware.append(MyMiddleware())
server.run(port: 8080)
