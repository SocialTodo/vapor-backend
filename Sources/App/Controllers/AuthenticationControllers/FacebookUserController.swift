import Vapor
import HTTP

final class FacebookUserController {
    let drop: Droplet

    init(droplet: Droplet){
        drop = droplet
    }
    
    //Mark: Authentication stuff
    
    public func authenticate(userId facebookUserId:Int, token facebookToken:String) throws -> FacebookUser? {
        if let loggedInUser = try cachedLogin(userId: facebookUserId, token: facebookToken) {
            return loggedInUser
        } else if let loggedInUser = try graphApiLogin(userId: facebookUserId, token: facebookToken) {
            return loggedInUser
        } else {
            return nil
        }
    }
    
    private func cachedLogin(userId facebookUserId:Int, token facebookToken:String) throws -> FacebookUser? {
        if let queriedUser = try FacebookUser.makeQuery().filter("facebookUserId", .equals, facebookUserId).first(), queriedUser.facebookToken == facebookToken {
            return queriedUser
        } else {
            return nil
        }
    }
    
    private func graphApiLogin(userId facebookUserId:Int, token facebookToken:String) throws -> FacebookUser? {
        let response = drop.authenticate(userId: facebookUserId, token: facebookToken)
        if response?.valid ?? false {
            if let query = try FacebookUser.makeQuery().filter("facebookUserId", .equals, facebookUserId).first() {
                return query
            } else {
                let profile = drop.userProfile(userId: facebookUserId, token: facebookToken)
                let newFacebookUser = FacebookUser(userId: facebookUserId, token: facebookToken, name: profile?.facebookName ?? "Firstname Lastname")
                try newFacebookUser.save()
                return newFacebookUser
            }
        } else {
            return nil
        }
    }
}

extension FacebookUserController: ResourceRepresentable {
    typealias Model = FacebookUser
    
    func index(req: Request) throws -> ResponseRepresentable {
        let apiRequestHeaders = ApiRequestHeaders(req)
        if let userId = apiRequestHeaders.facebookUserId, let token = apiRequestHeaders.token, let user = try self.authenticate(userId: userId, token: token) {
            return try TodoList.makeQuery().filter(TodoList.Keys.listOwnerId, .equals, user.id!).all().makeNode(in: nil).converted(to: JSON.self)
        }
    }
    
    func show(req: Request) throws -> {
        
    }
    
    func makeResource() -> Resource<FacebookUser> {
        return Resource(
            index: index,
            show: show
        )
    }
}
