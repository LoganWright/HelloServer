//
//  router.swift
//  HelloServer
//
//  Created by Logan Wright on 2/15/16.
//  Copyright © 2016 LoganWright. All rights reserved.
//

import Curassow
import Inquiline
import Nest

public let Routes = Router()

public typealias RequestHandler = Request -> ResponseType

public final class Router {
    
    private final var tree: [Method : Branch] = [:]
    
    private init() {}
    
    internal final func resolve(request: RequestType) -> ResponseType? {
        guard
            let method = Method(rawValue: request.method),
            let branch = tree[method]
            else { return nil }
        
        let request = Request(request: request)
        
        let generator = request
            .path
            .pathComponentGenerator()
        
        return branch.handle(request, comps: generator)
    }
    
    public final func add(method: Method, path: String, handler: RequestHandler) {
        let generator = path.pathComponentGenerator()
        let branch = tree[method] ?? Branch(name: "")
        branch.extendBranch(generator, handler: handler)
        tree[method] = branch
    }
}

extension String {
    private func pathComponentGenerator() -> AnyGenerator<String> {
        let comps = self
            .characters
            .split { $0 == "/" }
            .map(String.init)
        
        var idx = 0
        return AnyGenerator<String> {
            guard idx < comps.count else {
                return nil
            }
            let next = comps[idx]
            idx += 1
            return next
        }
    }
}
