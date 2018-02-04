import Foundation
import Vapor
import HTTP

extension Droplet {
    func userProfile(userId facebookUserId: Int, token facebookToken: String)
        -> FacebookProfileResponse? {
        do {
            let graphResponse = try self.client.get("https://graph.facebook.com/\(facebookUserId)",
                query: [ "input_token": facebookToken,
                         "access_token": accessToken()])
            if let response = graphResponse.json?.object { return FacebookProfileResponse(response) }
                else { return nil }
        } catch {
            return nil
        }
    }

    func authenticate(userId facebookUserId: Int, token facebookToken: String)
        -> FacebookAuthenticationResponse? {
        do {
            let graphResponse = try self.client.get("https://graph.facebook.com/debug_token", query: [
                "input_token": facebookToken,
                "access_token": accessToken()
                ])
            if let response = graphResponse.json?.object?["data"]?.object { return FacebookAuthenticationResponse(response) }
                else { return nil }
        } catch {
            return nil
        }
    }
    
     func getFriendsForUser(userId facebookUserId: Int, token facebookToken: String) throws -> [FacebookUser] {
        let queryPageOfFriendsList: ([String:NodeRepresentable], FacebookFriendResponse) throws -> () =
            { query, facebookFriendResponse in
                do {
                    let graphResponse = try self.client.get("https://graph.facebook.com/\(facebookUserId)/friends", query: query)
                    //let test = graphResponse.json?.object!["data"]
                    try facebookFriendResponse.parseResponseAndAddFriends(res: graphResponse)
                }
            }
        let facebookFriendResponse = FacebookFriendResponse()
        repeat {
            if let current_page = facebookFriendResponse.next {
                try queryPageOfFriendsList([
                    "input_token": facebookToken,
                    "access_token": accessToken(),
                    "after": current_page
                    ], facebookFriendResponse)
            } else {
                try queryPageOfFriendsList([
                    "input_token": facebookToken,
                    "access_token": accessToken()
                    ], facebookFriendResponse)
            }
        } while facebookFriendResponse.addedFriends
        
        return facebookFriendResponse.facebookFriends
    }
    
    public func accessToken() -> String {
        if let appId = ProcessInfo.processInfo.environment["SOCIAL_TODO_APP_ID"],
           let appSecret = ProcessInfo.processInfo.environment["SOCIAL_TODO_APP_SECRET"] {
            return appId + "|" + appSecret
        }
        return ""
    }
}
