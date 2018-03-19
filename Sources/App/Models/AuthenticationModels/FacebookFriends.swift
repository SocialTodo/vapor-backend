import Vapor
import Fluent

final class FacebookFriends: PivotProtocol, Entity {
    var storage = Storage()

    public var leftId: Identifier
    public var rightId: Identifier
    
    typealias Left = FacebookUser
    typealias Right = FacebookUser

    static var leftIdKey: String = FacebookUser.foreignIdKey + "From"
    static var rightIdKey: String = FacebookUser.foreignIdKey + "To"
    
    required init(row: Row) throws {
        leftId = try row.get(FacebookFriends.leftIdKey)
        rightId = try row.get(FacebookFriends.rightIdKey)
        id = try row.get(idKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(idKey, id)
        try row.set(FacebookFriends.leftIdKey, leftId)
        try row.set(FacebookFriends.rightIdKey, rightId)
        return row
    }
    
}

extension FacebookFriends: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) {
            $0.id()
            $0.foreignId(for: Left.self, foreignIdKey: FacebookFriends.leftIdKey)
            $0.foreignId(for: Right.self, foreignIdKey: FacebookFriends.rightIdKey)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
