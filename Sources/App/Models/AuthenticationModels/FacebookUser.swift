import Vapor
import FluentProvider
import AuthProvider
import HTTP

final class FacebookUser: Model {
    //Fluent uses the storage to put fluent specific things onto it
    let storage = Storage()

    //Set up fields
    var name: String
    var facebookUserId: String
    var facebookToken: String
    var facebookFriends: Siblings<FacebookUser, FacebookUser, Pivot<FacebookUser,FacebookUser>> {
        return siblings()
    }
    var todoLists: Children<FacebookUser, TodoList> {
        return children()
    }

    struct Keys {
        static let name = "name"
        static let facebookUserId = "facebookUserId"
        static let facebookToken = "facebookToken"
    }

    init(userId facebookUserId:String, token facebookToken:String, name:String){
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
        // This is a temporary workaround; deletes all the models then re-adds the ones passed.
        try facebookFriends.delete()
        try friendFacebookUsers.forEach{ try facebookFriends.add($0) }
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.facebookToken, facebookToken)
        try row.set(Keys.facebookUserId, facebookUserId)
        return row
    }
}

extension FacebookUser {
    func didCreate() {
        guard let userId = self.id else {
            print("id error when creating token")
            return
        }
        let token = FacebookToken(token: facebookToken, userId: userId)
        try! token.save()
       
    }
}

extension FacebookUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) {
            $0.id()
            $0.string(Keys.facebookUserId)
            $0.string(Keys.facebookToken)
            $0.string(Keys.name)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension FacebookUser: JSONInitializable {
    convenience init(json: JSON) throws {
        try self.init(userId: json.get("userId"),
                      token: json.get("token"),
                      name: json.get("name"))
    }
}

extension FacebookUser: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("userId", facebookUserId)
        try json.set("token", facebookToken)
        try json.set("name", name)
        return json
    }
}

extension FacebookUser: ResponseRepresentable { }

extension FacebookUser: TokenAuthenticatable {
    public typealias TokenType = FacebookToken
}

extension Request {
    func user() throws -> FacebookUser {
        return try auth.assertAuthenticated()
    }
}


