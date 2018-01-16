import Foundation
import Vapor
import HTTP

final class GraphApiService {
    var drop: Droplet

    init(droplet: Droplet) {
        drop = droplet
    }


    func authenticate(userId facebookUserId:String, token facebookToken:String) throws {
        let graphResponse = try drop.client.get("https://graph.facebook.com/debug_token", query: [
            "input_token": facebookToken,
            "access_token": drop.accessToken()
            ])
        print(graphResponse)
    }
}

extension Droplet {
    public func accessToken() -> String {
        if let appId = ProcessInfo.processInfo.environment["SOCIAL_TODO_APP_ID"],
           let appSecret = ProcessInfo.processInfo.environment["SOCIAL_TODO_APP_SECRET"] {
            return appId + "|" + appSecret
        }
        return ""
    }
}
