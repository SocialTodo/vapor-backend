import Vapor
import HTTP

final class TodoListController {
    let drop: Droplet
    let userController: FacebookUserController
    
    init(droplet: Droplet, userController facebookUserController: FacebookUserController){
        drop = droplet
        userController = facebookUserController
    }
}

extension TodoListController: ResourceRepresentable {
    typealias Model = TodoList
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try userController.getResponse(req) { user in
            return try Response(status: Status.ok, body: TodoList.makeQuery().filter(TodoList.Keys.listOwnerId, .equals, user.id!).all().map{try $0.makeNode(in: nil).converted(to: JSON.self)}.makeJSON())
        }
    }
    
    func store(_ req: Request) throws -> ResponseRepresentable {
        return try userController.getResponse(req) { user in
            guard var json = req.json else { return Response(status: Status.badRequest) }
            do {
                try json.set(FacebookUser.foreignIdKey, user.id!)
                let newTodoList = try TodoList(node: json)
                try newTodoList.save()
                return Response(status: Status.ok, body: try newTodoList.makeNode().converted(to: JSON.self))
            } catch {
                print(error)
                return Response(status: Status.badRequest)
            }
        }
    }

    func show(_ req: Request, _ todoList: Model) throws -> ResponseRepresentable {
        return try userController.getResponse(req) { _ in
            return try Response(status: Status.ok, body: TodoItem.makeQuery().filter(TodoItem.Keys.parentListId, .equals, todoList.id!).all().map{try $0.makeNode(in: nil).converted(to: JSON.self)}.makeJSON())
            //return try todoList.makeNode().converted(to: JSON.self)
        }
    }
    
    func update(_ req: Request, _ todoList: Model) throws -> ResponseRepresentable {
        return try userController.getResponse(req) { _ in
            guard let json = req.json else { return Response(status: Status.badRequest) }
            do {
                todoList.update(node: json.converted(to: Node.self))
                try todoList.save()
                return Response(status: Status.ok, body: try todoList.makeNode().converted(to: JSON.self))
            } catch { return Response(status: Status.badRequest) }
        }
    }
    
    func destroy(_ req: Request, _ todoList: Model) throws -> ResponseRepresentable {
        return try userController.getResponse(req){ _ in
            try todoList.listItems.delete()
            try todoList.delete()
            return Response(status: Status.ok)
        }
    }
    
    func makeResource() -> Resource<TodoList> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            destroy: destroy
        )
    }
}


