//
//  main.swift
//  HelloServer
//
//  Created by Logan Wright on 2/12/16.
//  Copyright © 2016 LoganWright. All rights reserved.
//

import Foundation
//import Vapor
import PureJsonSerializer
import Genome
import Curassow
import Inquiline
import Nest

let FourOhFour = Response(.Ok, contentType: "text/plain", body: "404 Not Found")

Routes.add(.GET, path: "/") { request in
    let json: Json = [
        "Hello" : "Server Side Swift",
        "Featured Libraries" : [
            "Genome" : "https://github.com/loganwright/genome",
            "PureJsonSerializer" : "https://github.com/gfx/Swift-PureJsonSerializer",
            "Curassow" : "https://github.com/kylef/curassow",
            "Inquiline" : "https://github.com/kylef/inquiline",
            "Nest" : "https://github.com/nestproject/nest"
        ],
        "BuildPack" : "https://github.com/kylef/heroku-buildpack-swift",
        "Hosted On" : "Heroku"
    ]
    
    let resp = json.serialize(.PrettyPrint)
    return Response(.Ok, contentType: "application/json", body: resp)
}

Routes.add(.GET, path: "/resource/:type/:name") { req in
    print("Processing: \(req)")
    guard
        let name = req.arguments["name"],
        let type = req.arguments["type"],
        let resourceResp = ResourceResponse(status: .Ok, fileName: name, type: type)
        else { return FourOhFour }
    
    print("Got resp response: \(req)")
    return resourceResp
}

Routes.add(.GET, path: "/hello") { request in
    return Response(.Ok, contentType: "text/plain", body: "Hello, World!\n\n\(request)")
}

// MARK: In memory for now

var hello_names: [String] = []

func helloHandler(request: Request) -> ResponseType {
    guard let name = request.arguments["name"] else {
        return FourOhFour
    }
    hello_names.append(name)
    if hello_names.count > 50 {
        hello_names = Array(hello_names.suffixFrom(1)) // Drop first
    }
    
    let names: Json = Json(hello_names.map { Json($0) } )
    let js: Json = [
        "hello" : Json(name),
        "meet" : names
    ]
    return Response(.Ok, contentType: "application/json", body: js.serialize(.PrettyPrint))
}

Routes.add(.GET, path: "/hello/:name", handler: helloHandler)

// MARK: Public
public func run(port: UInt16 = 8080) {
    serve(port) { request in
        return Routes.resolve(request)
            ?? FourOhFour
    }
}

run(9000)


