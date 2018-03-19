import Foundation
import Vapor
import HTTP

enum GraphApiResponse {
    case authentication(FacebookAuthenticationResponse)
    case friends(FacebookFriendResponse)
    case profile(FacebookProfileResponse)
    case failure
}

struct FacebookCredentials {
    let userId: String
    let token: String
}

protocol GraphApiRequest {
    var client: Client { get }
    var facebookUserId: String { get }
    var facebookToken: String { get }
    var graphApiResponse: Promise<GraphApiResponse> { get }
    
    func run() -> Future<GraphApiResponse>

/*

    func userProfile(userId facebookUserId: Int, token facebookToken: String) -> Future<FacebookProfileResponse> {
        do {
            try client!.get(url:
                URI(path: "https://graph.facebook.com/\(facebookUserId)",
                    query: [
                        "input_token": facebookToken,
                        "access_token": accessToken()
                    ]
                )
                ).do { response in
                    if let result = response.json?.object {
                        response = FacebookProfileResponse(result)
                    }
            }
        } catch {
            return nil
        }
    }


    
     func getFriendsForUser(userId facebookUserId: Int, token facebookToken: String) throws -> Future<[FacebookUser]> {
        let queryPageOfFriendsList: ([String:NodeRepresentable], FacebookFriendResponse) throws -> () =
            { query, facebookFriendResponse in
                do {
                    let graphResponse = try client!.get(url:
                        URI(path: "https://graph.facebook.com/\(facebookUserId)/friends",
                            query: query)
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
 */
}

extension GraphApiRequest {
    //Generates the access token used for the Facebook API
    internal func accessToken() -> String {
        if let appId = ProcessInfo.processInfo.environment["SOCIAL_TODO_APP_ID"],
            let appSecret = ProcessInfo.processInfo.environment["SOCIAL_TODO_APP_SECRET"] {
            return appId + "|" + appSecret
        }
        return ""
    }
    
    internal func constructRequest(_ req: Request, _ credentials: FacebookCredentials) throws {
        do {
            self.facebookUserId = credentials.userId
            self.facebookToken = credentials.token
            // Create a HTTP outgoing client in the context of the current request
            self.client = try req.make(EngineClient.self)
            // Create a promise in the event loop
            self.graphApiResponse = req.eventLoop.newPromise(GraphApiRequest.self)
        } catch {
            print("INTERNAL ERROR: Was not able to create HTTP client from request.")
            throw error
        }
    }
}


