import Vapor
import Foundation
import MongoKitten
import BSON

// MARK: Mongo

// Get real password, change database, and use heroku config variable https://devcenter.heroku.com/articles/mongolab
let mongoUrl = "mongodb://test-user:test-password@ds015859.mlab.com"
let collection: MongoKitten.Collection?
let errorMessage: String?
do {
    let server = try MongoKitten.Server(host: "ds015859.mlab.com", authentication: (username: "test-user", password: "test-password"), port: 15859)
    try server.connect()
    collection = server["heroku_fdl1swgg"]["hello-names"]
    errorMessage = ""
} catch {
    collection = nil
    print(error)
    errorMessage = "ERROR: \(error)"
}

print("Err: \(errorMessage)")
print("")

// Create:
//try collection.insert(["username": "henk", "age": 245])
//
//// Read:
//try collection.find("username" == "henk") // Cursor<Document>
//try collection.findOne("username" == "henk") // Document?
//
//// Update:
//try collection.update("username" == "henk", ["$set": ["username": "fred"]], flags: [.Upsert])
//
//// Delete:
//try collection.remove("age" > 24)

// MARK: Vapor

public enum Error: ErrorType {
    case Failure
}

let up = Error.Failure

public func loadResource(name: String) -> NSData? {
    let path = Application.workDir + "Resources" + "/\(name.uppercaseString).xml"
    return NSData(contentsOfFile: path)
}

// MARK: Application

let app = Application()
//
app.get("query", String.self) { req, name in
    let cursor = try collection?.query("name" == name)
    let doc: Document! = nil
    if let person = cursor?.generate().next()?["name"] {
        print("Name: \(person)")
        let data = person.bsonData
        let d = NSData(bytes: data, length: data.count)
        let s = String(data: d, encoding: NSUTF8StringEncoding) ?? "OH NO"
        return Response(status: .OK, data: "You found: \(s)".utf8, contentType: .Html)
    } else {
        try collection?.insert(["name" : name])
        return Response(status: .OK, text: "Machine Broke: \(errorMessage)")
    }
}

app.get("ota/:product-id") { request in
    guard let name = request.parameters["product-id"], let resource = loadResource(name) else {
        throw up
    }
    
    return Response(status: .OK, data: resource, contentType: .Other("application/xml"))
}

app.get("test") { req in
    return "Test Successful"
}

func insertIfNecessary(name: String) throws {
    if let _ = try collection?.queryOne("name" == name)?["name"] {
    } else {
        try collection?.insert(["name" : name])
    }
}

func allPeople() throws -> [String] {
    let cursor = try collection?.query().generate()
    var people: [String] = []
    while let data = cursor?.next()?["name"]?.bsonData {
        let d = NSData(bytes: data, length: data.count)
        let s = String(data: d, encoding: NSUTF8StringEncoding) ?? "OH NO"
        people.append(s)
    }
    return people
}

app.get("hello") { req in
    return try Json(try allPeople())
}

app.get("hello", String.self) { req, name in
    let br = "<br>"
    var message = "Hello, \(name)!\(br)\(br)"
    
    let people = try allPeople()
    var peopleMsg = "I've also said hello to:\(br)\(br)"
    peopleMsg += people
        .map { name -> String in return "\t\(name),\(br)" }
        .reduce("", combine: +)
    
    
    try insertIfNecessary(name)
    
    let html = "<p>" + message + peopleMsg + "</p>"
    return Response.init(status: .OK, html: html)
}

app.start(port: 9090)