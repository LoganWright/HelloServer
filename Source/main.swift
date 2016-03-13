import Vapor
import Foundation

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