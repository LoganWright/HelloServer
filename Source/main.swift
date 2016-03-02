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

extension NSData: SequenceType {
    public func generate() -> UnsafeBufferPointer<UInt8>.Generator {
        return UnsafeBufferPointer<UInt8>(start: UnsafePointer<UInt8>(self.bytes), count: self.length).generate()
    }
}

// MARK: Application

let app = Application()


app.get("ota/:product-id") { request in
    guard let name = request.parameters["product-id"], let resource = loadResource(name) else {
        throw up
    }
    
    return Response(status: .OK, data: resource, contentType: .Other("xml"))
}


app.start(port: 9090)