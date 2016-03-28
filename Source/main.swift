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
    let server = try MongoKitten.Server(at: "ds015859.mlab.com", port: 15859, using: (username: "test-user", password: "test-password"))
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

typealias Byte = UInt8
extension NSData {
    internal func arrayOfBytes() -> [Byte] {
        let count = self.length / sizeof(Byte)
        var bytesArray = [Byte](repeating: 0, count: count)
        self.getBytes(&bytesArray, length:count * sizeof(Byte))
        return bytesArray
    }
}

public enum Error: ErrorProtocol {
    case Failure
}

let up = Error.Failure



extension Swift.Collection where Iterator.Element == UInt8 {
    
    public func toString() throws -> String {
        var utf = UTF8()
        
        #if swift(>=3.0)
            var gen = self.makeIterator()
        #else
            var gen = self.generate()
        #endif
        
        var str = String()
        
        #if swift(>=3.0)
            while true {
                switch utf.decode(&gen) {
                case .emptyInput: //we're done
                    return str
                case .error: //error, can't describe what however
                    throw up
//                    throw Error.ParseStringFromCharsFailed(Array(self))
                case .scalarValue(let unicodeScalar):
                    str.append(unicodeScalar)
                }
            }
        #else
            while true {
            switch utf.decode(&gen) {
            case .EmptyInput: //we're done
            return str
            case .Error: //error, can't describe what however
            throw Error.ParseStringFromCharsFailed(Array(self))
            case .Result(let unicodeScalar):
            str.append(unicodeScalar)
            }
            }
        #endif
    }
    
}

// MARK: Application

let app = Application()

public func loadResource(name: String) -> NSData? {
    let path = app.workDir + "Resources" + "/\(name.uppercased()).xml"
    return NSData(contentsOfFile: path)
}

//
app.get("query", String.self) { req, name in
    let cursor = try collection?.query(matching: "name" == name)
    let doc: Document! = nil
    if let person = cursor?.makeIterator().next()?["name"] {
        print("Name: \(person)")
        let data = person.bsonData
        let d = NSData(bytes: data, length: data.count)
        let s = String(data: d, encoding: NSUTF8StringEncoding) ?? "OH NO"
        return Response(status: .OK, data: "You found: \(s)".utf8, contentType: .Html)
    } else {
        let _ = try collection?.insert(["name" : name])
        return Response(status: .OK, text: "Machine Broke: \(errorMessage)")
    }
}

app.get("ota/:product-id") { request in
    guard let name = request.parameters["product-id"], let resource = loadResource(name) else {
        throw up
    }
    
    return Response(status: .OK, data: resource.arrayOfBytes(), contentType: .Other("application/xml"))
}

app.get("test") { req in
    return "Test Successful"
}

app.get("json") { req in
    return Json([
        "dict" : [
            "name" : "Vapor",
            "lang" : "Swift"
        ],
        "number" : 123,
        "array" : [
            0,
            1,
            2,
            3
        ],
        "string" : "test"
        ])
}

extension String {
    init?(bytes: [UInt8]) {
        let signedData = bytes.map { byte in
            return Int8(byte)
        }
        
        guard let string = String(validatingUTF8: signedData) else {
            return nil
        }
        
        self = string
    }
}
func insertIfNecessary(name: String) throws {
    if let _ = try collection?.queryOne(matching: "name" == name)?["name"] {
    } else {
        let _ = try collection?.insert(["name" : name])
    }
}

func allPeople() throws -> [String] {
    let cursor = try collection?.query().makeIterator()
    var people: [String] = []
    while let data = cursor?.next()?["name"]?.bsonData {
//        let d = NSData(bytes: data, length: data.count)
//        let s = NSString(data: d, encoding: NSUTF8StringEncoding) ?? "OH NO"
//        let s = try data.string()
        people.append(try data.toString())
    }
    return people
}

app.get("hello") { req in
    let peeps = try allPeople().map { Json($0) }
    return Json.array(peeps)
}

app.get("hello", String.self) { req, name in
    let br = "<br>"
    var message = "Hello, \(name)!\(br)\(br)"
    
    let people = try allPeople()
    var peopleMsg = "I've also said hello to:\(br)\(br)"
    peopleMsg += people
        .map { name -> String in return "\t\(name),\(br)" }
        .reduce("", combine: +)
    
    print("Will insert")
    try insertIfNecessary(name)
    print("Did Insert")
    let html = "<p>" + message + peopleMsg + "</p>"
    return Response.init(status: .OK, html: html)
}

app.start(port: 9090)
