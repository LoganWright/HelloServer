import Vapor
import Foundation
import MongoKitten
import BSON

// MARK: Mongo

let mongoUrl = "mongodb://heroku-one:testing@ds015859.mlab.com:15859/heroku_fdl1swgg"
let collection: MongoKitten.Collection?
let errorMessage: String?
do {
    let server = try MongoKitten.Server(host: "127.0.0.1")
    try server.connect()
    collection = server["heroku_fdl1swgg"]["users"]
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
    let cursor = try collection?.find("name" == name)
    let doc: Document! = nil
    if let person = cursor?.generate().next()?["name"] {
        print("Name: \(person)")
        let data = person.bsonData
        let d = NSData(bytes: data, length: data.count)
        let s = String(data: d, encoding: NSUTF8StringEncoding) ?? "OH NO"
        return Response(status: .OK, data: person.bsonData, contentType: .Html)
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

app.start(port: 9090)