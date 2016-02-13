//
//  main.swift
//  HelloServer
//
//  Created by Logan Wright on 2/12/16.
//  Copyright © 2016 LoganWright. All rights reserved.
//

import Foundation
import Vapor

Route.get("/") { request in
    let json = [
        [ "hello" : "world" ],
        [ "hello" : "mars" ]
    ]
    return try Response(status: Response.Status.OK, json: json)
}

Route.get("/hello") { request in
    return ["Hello" : "World"]
}

Route.get("test") { request in
    print("Request: \(request)")
    let json = [
        "hello",
        "array"
    ]
    return try Response(status: Response.Status.OK, json: json)
}

Route.post("test") { request in
    print("Request: \(request)")
    let json = [
        "hello",
        "array"
    ]
    return try Response(status: Response.Status.OK, json: json)
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
