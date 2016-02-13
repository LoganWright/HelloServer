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
    return ["Hello" : "World"]
}

let server = Server()
server.run(port: 8080)
