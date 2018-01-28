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

    private func getResponse(_ req: Request, _ query: (FacebookUser) throws -> (ResponseRepresentable)) throws -> ResponseRepresentable {
        let apiRequestHeaders = ApiRequestHeaders(req)
        //For some reason, if this optional is part of the conditional statement, it unwraps to a completley different value. I have no idea why, but this is a workaround for now
        let facebookUserId = apiRequestHeaders.facebookUserId ?? 0
        if let token = apiRequestHeaders.token, let user = try userController.authenticate(userId: Int(truncatingIfNeeded: facebookUserId), token: token) {
            return try query(user)
        } else {
            return Response(status: Status.badRequest)
        }
    }
    
    func store(_ req: Request) throws -> ResponseRepresentable {
        return try getResponse(req) { _ in
            guard let json = req.json else { return Response(status: Status.badRequest) }
            do {
                let newTodoItem = try TodoItem(node: json)
                try newTodoItem.save()
                return Response(status: Status.ok, body: try newTodoItem.makeNode().converted(to: JSON.self))
            } catch { return Response(status: Status.badRequest) }
        }
    }

    func show(_ req: Request, _ id: Model) throws -> ResponseRepresentable {
        return try getResponse(req) { user in
            return try id.makeNode().converted(to: JSON.self)
        }
    }
    
    func update(_ req: Request, _ id: Model) throws -> ResponseRepresentable {
        return try getResponse(req) { _ in
            guard let json = req.json else { return Response(status: Status.badRequest) }
            do {
                id.update(node: json.converted(to: Node.self))
                try id.save()
                return Response(status: Status.ok, body: try id.makeNode().converted(to: JSON.self))
            } catch { return Response(status: Status.badRequest) }
        }
    }
    
    func makeResource() -> Resource<TodoItem> {
        return Resource(
            store: store,
            show: show,
            update: update
        )
    }
}
