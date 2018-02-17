import HTTP
import Vapor
import Foundation

class FacebookAuthenticationResponse {
    let valid: Bool?
    let expiration: Date?
    let permissions: [String?]?
    let facebookUserId: Int?

    init(_ response: [String:JSON]){
        valid = response["is_valid"]?.bool
        if (valid ?? false){
            //Refactor this mess of NSDate
            //expiration = NSDate(timeIntervalSince1970: Double(response["expires_at"]!.int!)) as! Dates
            expiration = nil
            permissions = response["scopes"]?.array?.map{ $0.string }
            facebookUserId = response["user_id"]?.int
        } else {
            expiration = nil
            permissions = nil
            facebookUserId = nil
        }
    }
}
