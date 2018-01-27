import HTTP
import Vapor

class ApiRequestHeaders {
    let facebookUserId: UInt64?
    let token: String?
    let listOwnerId: Int?
    
    init(_ req: Request){
        facebookUserId = (req.headers["user_id"]?.string).toLong()
        token = req.headers["token"]?.string
        listOwnerId = (req.headers["owner_id"]?.string).toInt()
    }
}

extension Optional
where Wrapped == String {
    func toInt() -> Int? {
        if let str = self {
            return Int(str)
        } else {
            return nil
        }
    }
    
    func toLong() -> UInt64? {
        if let str = self {
            return UInt64(str)
        } else {
            return nil
        }
    }
}
