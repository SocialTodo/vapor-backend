import Foundation
import Vapor
import HTTP

// A promise for the FacebookProfileAuthentication response.
// Will do a query out to facebook's graph api, and return a
// FacebookProfileResponse, which will have authentication
// information, along with permissions.
class GraphApiAuthenticationRequest: GraphApiRequest {
    var client: Client
    var facebookUserId: String
    var facebookToken: String
    var graphApiResponse: Promise<GraphApiResponse>
    
    init(_ req: Request, _ credentials: FacebookCredentials) throws {
        try constructRequest(req, credentials)
    }
    
    func run()  -> Future<GraphApiResponse> {
        DispatchQueue.global(qos: .background).async {
            //Eventually, the .failure should correspond to a failure response
            //and there should be a seperate response for server errors
            if let res = self.authenticate() {
                self.graphApiResponse.complete(.authentication(res))
            } else {
                self.graphApiResponse.complete(.failure)
            }
        }
        return graphApiResponse.future
    }
    
    func authenticate() -> FacebookAuthenticationResponse? {
        let query = ["input_token": facebookToken, "access_token": accessToken()]
        do {
            client.get(
                URI(path:"https://graph.facebook.com/debug_token",
                    query: query
                )
                ).do { response in
                    if let result = response.json?.object?["data"]?.object {
                        return FacebookAuthenticationResponse(response)
                    } else {
                        return nil
                    }
            }
        } catch {
            return nil
        }
    }
    
}
