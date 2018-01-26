import Vapor

extension Droplet {
    func setupRoutes() throws {
        
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
