import Vapor
import AuthProvider
import FluentProvider


extension Droplet {
    func setupRoutes() throws {
        let tokenMiddleware = TokenAuthenticationMiddleware(FacebookUser.self)
        let authed = grouped(tokenMiddleware)
        
        authed.get("me") { request in
            return try request.user()
        }

        get("users", Int.parameter) { request in
            let userId = try request.parameters.next(Int.self)
            guard let user = try FacebookUser.find(userId) else {
                throw Abort.notFound
            }
            return "User's name is \(user.name)"
        }

        
        post("users") { request in
            guard let json = request.json else {
                throw Abort.badRequest
            }
            let user = try FacebookUser(json: json)
            try user.save()
            return user
        }
    }
}
