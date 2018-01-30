import Foundation
import Vapor
import HTTP

extension Droplet {
    func userProfile(userId facebookUserId: Int, token facebookToken: String)
        -> FacebookProfileResponse? {
        do {
            let graphResponse = try self.client.get("https://graph.facebook.com/\(facebookUserId)",
                query: [ "input_token": facebookToken,
                         "access_token": accessToken() ])
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
    
    /*func getFriends(userId facebookUserId: Int, token facebookToken: String) {
        
    }*/
    
    public func accessToken() -> String {
        if let appId = ProcessInfo.processInfo.environment["SOCIAL_TODO_APP_ID"],
           let appSecret = ProcessInfo.processInfo.environment["SOCIAL_TODO_APP_SECRET"] {
            return appId + "|" + appSecret
        }
        return ""
    }
}
