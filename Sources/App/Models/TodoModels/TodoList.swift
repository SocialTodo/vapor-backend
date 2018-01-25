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
        static let title = "title"
        static let listOwnerId = FacebookUser.foreignIdKey
        static let shared = "shared"
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
        try row.set(Keys.shared, shared)
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
