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
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try getResponse(req) { user in
            return try Response(status: Status.ok, body: TodoList.makeQuery().filter(TodoList.Keys.listOwnerId, .equals, user.id!).all().map{try $0.makeNode(in: nil).converted(to: JSON.self)}.makeJSON())
        }
    }
    
    func store(_ req: Request) throws -> ResponseRepresentable {
        return try getResponse(req) { user in
            guard var json = req.json else { return Response(status: Status.badRequest) }
            do {
                try json.set(FacebookUser.foreignIdKey, user.id!)
                let newTodoList = try TodoList(node: json)
                try newTodoList.save()
                return Response(status: Status.ok, body: try newTodoList.makeNode().converted(to: JSON.self))
            } catch { return Response(status: Status.badRequest) }
        }
    }

    func show(_ req: Request, _ todoList: Model) throws -> ResponseRepresentable {
        return try getResponse(req) { _ in
            return try Response(status: Status.ok, body: TodoItem.makeQuery().filter(TodoItem.Keys.parentListId, .equals, todoList.id!).all().map{try $0.makeNode(in: nil).converted(to: JSON.self)}.makeJSON())
            //return try todoList.makeNode().converted(to: JSON.self)
        }
    }
    
    func update(_ req: Request, _ todoList: Model) throws -> ResponseRepresentable {
        return try getResponse(req) { _ in
            guard let json = req.json else { return Response(status: Status.badRequest) }
            do {
                todoList.update(node: json.converted(to: Node.self))
                try todoList.save()
                return Response(status: Status.ok, body: try todoList.makeNode().converted(to: JSON.self))
            } catch { return Response(status: Status.badRequest) }
        }
    }
    
    func destory(_ req: Request, _ todoList: Model) throws -> ResponseRepresentable {
        return try getResponse(req){ _ in
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
            update: update
        )
    }
}


