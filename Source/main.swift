import Vapor
import Foundation
import MongoKitten
import BSON

// MARK: Mongo

let mongoUrl = "mongodb://heroku-one:testing@ds015859.mlab.com:15859/heroku_fdl1swgg"
let collection: MongoKitten.Collection?
let errorMessage: String?
do {
    let server = try MongoKitten.Server(host: mongoUrl)
    try server.connect()
    collection = server["heroku_fdl1swgg"]["users"]
    errorMessage = ""
} catch {
    collection = nil
    errorMessage = "ERROR: \(error)"
}

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

app.get("query", String.self) { req, name in
    let cursor = try collection?.find("name" == name)
    if let docData = cursor?.generate().next()?.bsonData {
        return Response(status: .OK, data: docData, contentType: .Text)
    } else {
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