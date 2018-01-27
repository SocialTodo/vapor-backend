import Foundation
import Vapor
import HTTP

final class GraphApiService {
    var drop: Droplet

    init(droplet: Droplet) {
        drop = droplet
    }

    func userProfile(userId facebookUserId: Int, token facebookToken: String)
        -> FacebookProfileResponse? {
        do {
            let graphResponse = try drop.client.get("https://graph.facebook.com/\(facebookUserId)",
                query: [ "input_token": facebookToken,
                         "access_token": drop.accessToken() ])
            if let response = graphResponse.json?.object { return FacebookProfileResponse(response) }
                else { return nil }
        } catch {
            return nil
        }
    }

    func authenticate(token facebookToken: String)
        -> FacebookAuthenticationResponse? {
        do {
            let graphResponse = try drop.client.get("https://graph.facebook.com/debug_token", query: [
                "input_token": facebookToken,
                "access_token": drop.accessToken()
                ])
            if let response = graphResponse.json?.object?["data"]?.object { return FacebookAuthenticationResponse(response) }
                else { return nil }
        } catch {
            return nil
        }
    }
    
    /*func friendsList(userId facebookUserID: String token facebookToken: String)
        -> [String: JSON]? {
        
     }*/
}

extension Droplet {
    public func accessToken() -> String {
        if let appId = ProcessInfo.processInfo.environment["SOCIAL_TODO_APP_ID"],
           let appSecret = ProcessInfo.processInfo.environment["SOCIAL_TODO_APP_SECRET"] {
            return appId + "|" + appSecret
        }
        return ""
    }
    public func getUserInfo(token: String) throws -> [String: String] {
        var userInfo = [String: String]()
        let graph = GraphApiService.init(droplet: self)
        guard let authResponse = graph.authenticate(token: token) else {
            throw Abort.serverError
        }
        guard let userId = authResponse.facebookUserId else {
            throw Abort.serverError
        }
        
        guard let userProfile = graph.userProfile(userId: userId, token: token) else {
            throw Abort.serverError
        }
        guard let name = userProfile.facebookName else {
            throw Abort.serverError
        }
        
        userInfo["userId"] = "\(userId)"
        userInfo["name"] = name
        
        return userInfo
    }
}
