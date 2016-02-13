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

public let method: Vapor.Request.Method
///Query data from the path, or POST data from the body (depends on `Method`).
public let data: [String : String]
///Browser stored data sent with every server request
public let cookies: [String : String]
///Path requested from server, not including hostname.
public let path: String
///Information or metadata about the `Request`.
public let headers: [String : String]
///Content of the `Request`.
public let body: [UInt8]
///Address from which the `Request` originated.
public let address: String?
///URL parameters (ex: `:id`).
public var parameters: [String : String]
///Server stored information related from session cookie.
public var session: Vapor.Session

Route.post("test") { request in
    print("Request: \(request)")
    return "success"
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
server.run(port: 80)
