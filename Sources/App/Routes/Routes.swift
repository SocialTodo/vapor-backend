import Vapor
import AuthProvider
import FluentProvider


extension Droplet {
    func setupRoutes() throws {
        let tokenMiddleware = TokenAuthenticationMiddleware(FacebookUser.self)
        let authed = grouped(tokenMiddleware)
        
        // get user by token
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

        // create a user with fb token
        post("users") { request in
            guard let json = request.json else {
                throw Abort.badRequest
            }
            let token:String = try json.get("token")
            let userInfo = try self.getUserInfo(token: token)
            
            let user = FacebookUser(userId: userInfo["userId"]!, token: token, name: userInfo["name"]!)
            try user.save()
            return user
        }
        
        
    }
}
