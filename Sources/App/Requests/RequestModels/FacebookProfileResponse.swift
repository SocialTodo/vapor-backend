import HTTP
import Vapor 

class FacebookProfileResponse {
    let facebookUserId: Int?
    let facebookName: String?
    
    init(_ response: [String:JSON]){
        facebookUserId = response["id"]!.int
        facebookName = response["name"]!.string
    }
}
