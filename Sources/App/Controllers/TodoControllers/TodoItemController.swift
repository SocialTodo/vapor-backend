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

    private func getResponse(_ req: Request,  _ query: (FacebookUser) throws -> (ResponseRepresentable)) throws -> ResponseRepresentable {
        let apiRequestHeaders = ApiRequestHeaders(req)
        if let userId = apiRequestHeaders.facebookUserId, let token = apiRequestHeaders.token, let user = try userController.authenticate(userId: Int(truncatingIfNeeded: userId), token: token) {
            return try query(user)
        } else {
            return Response(status: Status.badRequest)
        }
    }
    
    func show(_ req: Request, _ id: Any) throws -> ResponseRepresentable {
        return try getResponse(req) { user in
            return try req.parameters.next(TodoItem.self)
        }
    }
    
    /*func update(req: Request) throws -> ResponseRepresentable {
        
    }
    
    func store(req: Request) throws -> ResponseRepresentable {
        return try getResponse(req) { user in
            
        }
    }*/
    
    func makeResource() -> Resource<TodoItem> {
        return Resource(//create: create,
                        show: show
                        //update: update,
                        //destroy: destroy
        )
    }
    
    
    
}
