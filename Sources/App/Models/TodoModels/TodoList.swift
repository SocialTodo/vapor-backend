import Vapor
import FluentProvider
import HTTP

final class TodoList: Model {
    let storage = Storage()

    var title: String
    var shared: Bool
    var listOwnerId: Identifier
    var listOwner: Parent<TodoList, FacebookUser> {
        return parent(id: listOwnerId)
    }
    var listItems: Children<TodoList, TodoItem> {
        return children()
    }

    enum Keys {
        static let id = "id"
        static let title = "title"
        static let shared = "shared"
        static let listOwnerId = FacebookUser.foreignIdKey
    }
    init(title:String, listOwner: FacebookUser, shared: Bool) {
        self.title = title
        // Add error handling if the user hasn't been saved yet
        self.listOwnerId = listOwner.id!
        self.shared = shared
    }

    init(row: Row) throws {
        title = try row.get(Keys.title)
        listOwnerId = try row.get(Keys.listOwnerId)
        shared = try row.get(Keys.shared)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.title, title)
        try row.set(Keys.listOwnerId, listOwnerId)
        return row
    }
}

extension TodoList: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) {
            $0.id()
            $0.string(Keys.title)
            $0.string(Keys.listOwnerId)
            $0.bool(Keys.shared)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension TodoList: NodeConvertible {
    convenience init(node: Node) throws {
        id = Identifier(node[Keys.id]!.wrapped)
        title = node[Keys.title]!.string!
        listOwnerId = Identifier(node[Keys.listOwnerId]!.wrapped)
        shared = node[Keys.shared]!.bool!
    }
    
    convenience init(node: Node, in context: Context) throws {
        //Lots of force unwraps, but If any one of these fails, I think throwing an exception is the best way to handle it.
        id = Identifier(node[Keys.id]!.wrapped)
        title = node[Keys.title]!.string!
        listOwnerId = Identifier(node[Keys.listOwnerId]!.wrapped)
        shared = node[Keys.shared]!.bool!
    }

    func makeNode(in context: Context?) throws -> Node {
        return try Node.init(node:
            [
                Keys.id: id,
                Keys.title: title,
                Keys.listOwnerId: listOwnerId,
                Keys.shared: shared
            ]
        )
    }
}

extension TodoList: ResponseRepresentable {
    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set("title", title)
        try json.set("list_id", id)
        try json.set("list_items", listItems)
        return try json.makeResponse()
    }
}

