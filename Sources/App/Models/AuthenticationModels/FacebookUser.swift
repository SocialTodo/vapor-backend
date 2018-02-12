import Vapor
import FluentProvider
import HTTP

final class FacebookUser: Model {
    //Fluent uses the storage to put fluent specific things onto it
    let storage = Storage()

    //Set up fields
    var name: String
    var facebookUserId: Int
    var facebookToken: String
    
    var facebookFriends: Siblings<FacebookUser, FacebookUser, FacebookFriends> {
        return siblings(to: FacebookUser.self, through: FacebookFriends.self, localIdKey: FacebookUser.foreignIdKey + "From", foreignIdKey: FacebookUser.foreignIdKey + "To")
    }
    var todoLists: Children<FacebookUser, TodoList> {
        return children()
    }

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let facebookUserId = "facebookUserId"
        static let facebookToken = "facebookToken"
    }

    init(userId facebookUserId:Int, token facebookToken:String, name:String){
        self.name = name
        self.facebookUserId = facebookUserId
        self.facebookToken = facebookToken
    }

    init(row: Row) throws {
        name = try row.get(Keys.name)
        facebookUserId = try row.get(Keys.facebookUserId)
        facebookToken = try row.get(Keys.facebookToken)
    }

    func setFriends(friends friendFacebookUsers:[FacebookUser]) throws {
        //If you try to use the ORM here, it will try to do a INNER JOIN inside of a DELETE, which isn't supported in SQLite
        try FacebookFriends.database?.raw("DELETE FROM `facebook_friendss` WHERE `\(FacebookUser.foreignIdKey + "From")` = \(id!.wrapped)")
        try friendFacebookUsers.forEach{ try facebookFriends.add($0) }
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.facebookUserId, facebookUserId)
        try row.set(Keys.facebookToken, facebookToken)
        return row
    }

}

extension FacebookUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) {
            $0.id()
            $0.int(Keys.facebookUserId, unique: true)
            $0.string(Keys.facebookToken)
            $0.string(Keys.name)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension FacebookUser: NodeConvertible {
    convenience init(node: Node) throws {
            self.init(
                userId: node[Keys.facebookUserId]!.int!,
                token: node[Keys.facebookToken]!.string!,
                name: node[Keys.name]!.string!
            )
    }

    func makeNode(in context: Context? = nil) throws -> Node {
        return try Node.init(node:
            [
                //To silence an error
                Keys.id: id as Any,
                Keys.name: name,
                Keys.facebookUserId: facebookUserId,
                Keys.facebookToken: facebookToken
            ]
        )
    }
}

extension FacebookUser: ResponseRepresentable {
    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set("id", id!)
        try json.set(Keys.facebookUserId, facebookUserId)
        try json.set(Keys.name, name)
        try json.set("lists", try todoLists.all().map{try $0.makeNode()})
        return try json.makeResponse()
    }
}
