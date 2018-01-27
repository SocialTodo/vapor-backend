import Vapor
import HTTP

final class TodoItemController {
    typealias Model = TodoItem

    let drop: Droplet
    let userController: FacebookUserController
    
    init(droplet: Droplet, userController facebookUserController: FacebookUserController){
        drop = droplet
        userController = facebookUserController
    }
    
    //Mark: CRUD
    
    func getTodoItemsForList(req: Request) throws -> ResponseRepresentable {
        let headers = ApiRequestHeaders(req)
        let listId = try req.parameters.next(Int.self)
        
        if let user = try userController.authenticate(userId: headers.facebookUserId!, token: headers.token!) {
            if let todoList = try getTodoItem(listId) {
                return try todoItem.makeResponse()
            } else {
                return Response(status: Status.badRequest)
            }
        } else {
            return Response(status: Status.forbidden)
        }
    }
    
    func createTodoItem(req: Request) throws -> ResponseRepresentable {
        let headers = ApiRequestHeaders(req)
        let listId = try req.parameters.next(Int.self)
        
        if let user = try userController.authenticate(userId: headers.facebookUserId!, token: headers.token!) {
            return try user.makeResponse()
        } else {
            return Response(status: Status.forbidden)
        }
    }
    
    func editTodoItem(req: Request) throws -> ResponseRepresentable {
        let headers = ApiRequestHeaders(req)
        if let user = try userController.authenticate(userId: headers.facebookUserId!, token: headers.token!) {
            return try user.makeResponse()
        } else {
            return Response(status: Status.forbidden)
        }
    }
    
    func deleteTodoItem(req: Request) throws -> ResponseRepresentable {
        let headers = ApiRequestHeaders(req)
        if let user = try userController.authenticate(userId: headers.facebookUserId!, token: headers.token!) {
            return try user.makeResponse()
        } else {
            return Response(status: Status.forbidden)
        }
    }
    
    func getTodoList(_ listId: Int) throws -> TodoItem? {
        return try TodoItem.makeQuery().find(listId)
    }
}
