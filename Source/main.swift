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
