import Vapor
import FluentProvider
import HTTP

final class TodoItem: Model {
    let storage = Storage()

    var title: String
    var checked: Bool
    private var parentListId: Identifier
    var parentList: Parent<TodoItem, TodoList> {
        return parent(id: parentListId)
    }

    enum Keys {
        static let id = "id"
        static let title = "title"
        static let checked = "checked"
        static let parentListId = TodoList.foreignIdKey
    }

    init(title:String, checked:Bool = false, parentListId: Int) {
        self.title = title
        self.checked = checked
        self.parentListId = Identifier(parentListId)
    }

    init(row: Row) throws {
        title = try row.get(Keys.title)
        checked = try row.get(Keys.checked)
        parentListId = try row.get(TodoList.foreignIdKey)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.title, title)
        try row.set(Keys.checked, checked)
        try row.set(TodoList.foreignIdKey, parentListId)
        return row
    }
}

extension TodoItem: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) {
            $0.id()
            $0.string(Keys.title)
            $0.bool(Keys.checked)
            $0.parent(TodoList.self)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension TodoItem: NodeConvertible {
    convenience init(node: Node) throws {
        self.init(
            title: node[Keys.title]!.string!,
            checked: node[Keys.checked]!.bool!,
            parentListId: node[Keys.parentListId]!.int!
        )
    }

    func makeNode(in context: Context? = nil) throws -> Node {
        return try Node.init(node:
            [
                //To silence a warning
                Keys.id: id as Any,
                Keys.title: title,
                Keys.checked: checked,
                Keys.parentListId: parentListId
            ]
        )
    }
}

extension TodoItem: ResponseRepresentable {
    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set("title", title)
        try json.set("checked", checked)
        return try json.makeResponse()
    }
}
