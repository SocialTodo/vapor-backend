import Vapor
import FluentProvider

final class FacebookToken: Model {
    let token: String
    let userId: Identifier
    let storage = Storage()
    
    var user: Parent<FacebookToken, FacebookUser> {
        return parent(id: userId)
    }
    
    init(row: Row) throws {
        token = try row.get("token")
        userId = try row.get("facebook_user_id")
    }
    
    init(token: String, userId: Identifier) {
        self.token = token
        self.userId = userId
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set("facebook_user_id", userId)
        return row
    }
}

extension FacebookToken: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { tokens in
            tokens.id()
            tokens.string("token")
            tokens.string("facebook_user_id")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}



