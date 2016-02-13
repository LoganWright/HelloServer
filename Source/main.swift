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

//let directory = DirectoryManager(directoryName: "database")

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
        print("Mapping json: \(map.node)")
        let msgg = map.node["message"]
        print("Message: \(msgg)")
        let msg: String = try map.extract("message")
        print("Got msg: \(msg)")
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

let TopToken = "-top"
let BottomToken = "-bottom"


Route.post("meme") { req in
    print("\n\n ******* \n\n MEME RAN \n\n ******* \(req) ******** \n\n \n\n ******** \n\n")
    var url = "http://urlme.me/"
    url += req.data["text"]?
        .characters
        .split { $0 == "+" }
        .flatMap { String($0) }
        .split { cmd in [TopToken, BottomToken].contains(cmd) }
        .map { comps in return comps.joinWithSeparator("%20") }
        .joinWithSeparator("/") ?? "success/sent%20a%20bad%20command/still%20got%20response"
 
    let js: Json = [
        "response_type" : "in_channel",
        "text" : "Here ya go!",
        "attachments" : [
            "text" : Json(url)
        ]
    ]
    return js.serialize(.PrettyPrint)
}
var messages: [Message] = []

Route.post("messages") { request in
    let js = try Json.deserialize(request.body)
    let message = try Message(data: js)
    let serialized = try message.jsonRepresentation().serialize(.PrettyPrint)
    messages.append(message)
    return serialized
}

Route.get("messages") { _ in
//    let messages = directory
//        .allFilesInDirectory
//        .flatMap { fileName -> String? in
//            return directory.fetchFileWithName(fileName)
//        }
//        .joinWithSeparator(",\n")
//    
//    var str = "[\n"
//    str += messages
//    str += "\n]"
    return Response(status: .OK, text: try messages.jsonRepresentation().serialize(.PrettyPrint))
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

Route.get("test/:id") { request in
    return ["Params" : "\(request.parameters)"]
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
