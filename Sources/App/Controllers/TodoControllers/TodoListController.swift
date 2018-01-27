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
    
    private func getResponse(_ req: Request,  _ query: (FacebookUser) throws -> (ResponseRepresentable)) throws -> ResponseRepresentable {
        let apiRequestHeaders = ApiRequestHeaders(req)
        if let userId = apiRequestHeaders.facebookUserId, let token = apiRequestHeaders.token, let user = try userController.authenticate(userId: Int(truncatingIfNeeded: userId), token: token) {
            return try query(user)
        } else {
            return Response(status: Status.badRequest)
        }
    }
    
    func store(req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else { return Response(status: Status.badRequest) }
        let newTodoItem = try TodoList(node: json)
        try newTodoItem.save()
        return Response(status: Status.ok)
    }

    func show(_ req: Request, _ id: Model) throws -> ResponseRepresentable {
        return try getResponse(req) { user in
            return try id.makeNode().converted(to: JSON.self)
        }
    }
    
    func makeResource() -> Resource<TodoList> {
        return Resource(
            store: store,
            show: show
            //update: update,
            //destroy: destroy
        )
    }
}


