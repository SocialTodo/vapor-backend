import Vapor
import HTTP

final class TodoItemController {
    let drop: Droplet
    let userController: FacebookUserController
    
    init(droplet: Droplet, userController facebookUserController: FacebookUserController){
        drop = droplet
        userController = facebookUserController
    }
}

extension TodoItemController: ResourceRepresentable {
    typealias Model = TodoItem

    func store(_ req: Request) throws -> ResponseRepresentable {
        do {
            return try userController.getResponse(req) { _ in
                guard let json = req.json else { return Response(status: Status.badRequest) }
                do {
                    let newTodoItem = try TodoItem(node: json)
                    try newTodoItem.save()
                    return Response(status: Status.ok, body: try newTodoItem.makeNode().converted(to: JSON.self))
                } catch { return Response(status: Status.badRequest) }
            }
        } catch { print(error); return Response(status: Status.internalServerError)}
    }

    func show(_ req: Request, _ todoItem: Model) throws -> ResponseRepresentable {
        do {
            return try userController.getResponse(req) { user in
                return try todoItem.makeNode().converted(to: JSON.self)
            }
        } catch { print(error); return Response(status: Status.internalServerError)}
    }
    
    func update(_ req: Request, _ todoItem: Model) throws -> ResponseRepresentable {
        do {
            return try userController.getResponse(req) { _ in
            guard let json = req.json else { return Response(status: Status.badRequest) }
            do {
                todoItem.update(node: json.converted(to: Node.self))
                try todoItem.save()
                return Response(status: Status.ok, body: try todoItem.makeNode().converted(to: JSON.self))
                } catch { return Response(status: Status.badRequest) }
            }
        } catch { print(error); return Response(status: Status.internalServerError)}
    }
    
    func destroy(_ req: Request, _ todoItem: Model) throws -> ResponseRepresentable {
        do {
            return try userController.getResponse(req) { _ in
                try todoItem.delete()
                return Response(status: Status.ok)
            }
        } catch { print(error); return Response(status: Status.internalServerError)}
    }
    
    func makeResource() -> Resource<TodoItem> {
        return Resource(
            store: store,
            show: show,
            update: update,
            destroy: destroy
        )
    }
}
