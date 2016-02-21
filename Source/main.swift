//
//  main.swift
//  HelloServer
//
//  Created by Logan Wright on 2/12/16.
//  Copyright © 2016 LoganWright. All rights reserved.
//

import Foundation
import Vapor
//import PureJsonSerializer
//import Genome

//check in file system
//let filePath = Server.workDir + "Public" + request.path
//
//let fileManager = NSFileManager.defaultManager()
//var isDir: ObjCBool = false

//if fileManager.fileExistsAtPath(filePath, isDirectory: &isDir) {
//    //file exists
//    if let fileBody = NSData(contentsOfFile: filePath) {
//        var array = [UInt8](count: fileBody.length, repeatedValue: 0)
//        fileBody.getBytes(&array, length: fileBody.length)
//        
//        return Response(status: .OK, data: array, contentType: .Text)
//    } else {
//        handler = { _ in
//            return Response(error: "Could not open file.")
//        }
//    }
//} else {
//    //default not found handler
//    handler = { _ in
//        return Response(status: .NotFound, text: "Page not found")
//    }
//}

enum Error: ErrorType {
    case NoFile
}

//extension Response {
//    static func fileResponse(directory: String = "./Public", resource: String) -> Response {
//        let filePath = directory + "/" + resource
//        
//        let fileManager = NSFileManager.defaultManager()
//        var isDir: ObjCBool = false
//        
//        if fileManager.fileExistsAtPath(filePath, isDirectory: &isDir) {
//            //file exists
//            if let fileBody = NSData(contentsOfFile: filePath) {
//                var array = [UInt8](count: fileBody.length, repeatedValue: 0)
//                fileBody.getBytes(&array, length: fileBody.length)
//    
//                // Should be public
//                return Response(status: .OK, data: array, contentType: .Text)
//            } else {
//                return Response(error: "Could not open file.")
//            }
//        } else {
//            //default not found handler
//            return Response(status: .NotFound, text: "Page not found")
//        }
//    }
//}
//
//Route.get("file/:file-name") { req in
//    guard let resourceName = req.parameters["file-name"] else {
//        throw Error.NoFile
//    }
//    
//    return Response.fileResponse(resourceName)
//}


extension NSData {
    func loadResource(directory: String = "./Public", name: String) -> [UInt8] {
        return []
    }
}

print("SwiftServerIO -- starting")

Route.get("hello") { _ in
    return "Hi there".stringByReplacingOccurrencesOfString("there", withString: "Logan")
//    return try Json(["Hello" : "World"])
}

Route.get("hello/:name") { request in
    let name = request.parameters["name"] ?? "World"
    return Json(["Hello" : Json(name)])
}

Route.get("complex-json-test") { req in
    let thing: [String : [String : Any]] = [
        "one" : [
            "hi" : "there"
        ],
        "two" : [
            "hi" : "again",
            "bye" : "sup"
        ]
    ]
    
    return try Response(status: .OK, json: thing)
}

Route.post("test") { request in
    var logs: [String : String] = [:]
    
//    print("0")
//    var bytes = request.data
//    let data = NSData(bytes: &bytes, length: bytes.count)
//    print("0.1")
//    let ns = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
//    print("0.1")
//    logs["nsraw"] = "\(ns)"
//    print("1")
    
    // Wouldn't allow this syntax
    // let string = ns["test"]?["string"] as? String
//    var value = "none"
//    let testObject = (ns as? [String : Any])?["test"] as? [String : Any]
//    let nsstring = testObject?["string"] as? String
//    logs["nsstring"] = nsstring ?? "no"
//    let nsnumber = testObject?["number"] as? Int
//    logs["nsnumber"] = "\(nsnumber ?? -1)"
//    let nsdouble = testObject?["double"] as? Double
//    logs["nsdouble"] = "\(nsdouble ?? -1.0)"
//    let nsarr = testObject?["nest"] as? [Int] ?? []
//    logs["nsarr"] = "\(nsarr)"
    
    print("two")
    
    let json = try Json.deserialize(request.body)
    logs["jsraw"] = "\(json)"
    
    let jsob = json["test"]
    let string = jsob?["string"]?.stringValue
    logs["jsstring"] = string ?? ""
    let number = jsob?["number"]?.intValue
    logs["jsnumber"] = "\(number ?? -1)"
    let double = jsob?["double"]?.doubleValue
    logs["jsdouble"] = "\(double ?? -1)"
    let arr = jsob?["nest"]?.arrayValue?.flatMap { $0.intValue } ?? []
    logs["jsarr"] = "\(arr)"
    
    return try Json(logs)
}

let server = Server()
server.run(port: 8080)


//
//let FourOhFour = Response(.Ok, contentType: "text/plain", content: "404 Not Found")
//
//Routes.add(.GET, path: "/") { request in
//    let json: Json = [
//        "Hello" : "Server Side Swift",
//        "Featured Libraries" : [
//            "Genome" : "https://github.com/loganwright/genome",
//            "PureJsonSerializer" : "https://github.com/gfx/Swift-PureJsonSerializer",
//            "Curassow" : "https://github.com/kylef/curassow",
//            "Inquiline" : "https://github.com/kylef/inquiline",
//            "Nest" : "https://github.com/nestproject/nest"
//        ],
//        "BuildPack" : "https://github.com/kylef/heroku-buildpack-swift",
//        "Hosted On" : "Heroku"
//    ]
//    
//    let resp = json.serialize(.PrettyPrint)
//    return Response(.Ok, contentType: "application/json", content: resp)
//}
//
//Routes.add(.GET, path: "/resource/:type/:name") { req in
//    print("Processing: \(req)")
//    guard
//        let name = req.arguments["name"],
//        let type = req.arguments["type"],
//        let resourceResp = ResourceResponse(status: .Ok, fileName: name, type: type)
//        else { return FourOhFour }
//    
//    print("Got resp response: \(req)")
//    return resourceResp
//}
//
//Routes.add(.GET, path: "/hello") { request in
//    return Response(.Ok, contentType: "text/plain", content: "Hello, World!\n\n\(request)")
//}
//
//// MARK: In memory for now
//
//var hello_names: [String] = []
//
//func helloHandler(request: Request) -> ResponseType {
//    guard let name = request.arguments["name"] else {
//        return FourOhFour
//    }
//    hello_names.append(name)
//    if hello_names.count > 50 {
//        hello_names = Array(hello_names.suffixFrom(1)) // Drop first
//    }
//    
//    let names: Json = Json(hello_names.map { Json($0) } )
//    let js: Json = [
//        "hello" : Json(name),
//        "meet" : names
//    ]
//    return Response(.Ok, contentType: "application/json", content: js.serialize(.PrettyPrint))
//}
//
//Routes.add(.GET, path: "/hello/:name", handler: helloHandler)
//
//// MARK: Public
//public func run(port: UInt16 = 8080) {
//    serve(port) { request in
//        return Routes.resolve(request)
//            ?? FourOhFour
//    }
//}
//
//run(8080)


