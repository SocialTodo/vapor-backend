
class ApiRequestHeaders {
    let facebookUserId: Int?
    let token: String?
    let listOwnerId: Int?
    
    init(_ req: Request){
        facebookUserId = req.query?["user_id"]?.int
        token = req.query?["token"]?.string
        listOwnerId = req.query?["owner_id"]?.int
    }
}
