import HTTP
import Vapor

class FacebookFriendResponse {
    var facebookFriends: [FacebookUser] = []
    var next: String?
    var addedFriends = true
    
    init () {}
    
    func parseResponseAndAddFriends(res graphResponse:Response) throws {
        if let response = graphResponse.json?.object?["data"] {
            //We heard you like closures, so we put closures in your closures so you can nest JSON while you nest JSON
            //I will refactor later I promise
            let newFriendIds = response.array.map{$0.flatMap{$0.object.flatMap{$0}}}.map{$0.flatMap{$0["id"]?.string}} ?? []
            if (newFriendIds.count > 0) {
                facebookFriends.append(contentsOf: try FacebookUser.makeQuery().filter(FacebookUser.Keys.facebookUserId, in:newFriendIds).all())
            } else {
                addedFriends = false
            }
        }
        if let response = graphResponse.json?.object?["paging"]?.object?["cursors"]?.object?["after"]?.string {
            next = response
        }
    }
}
