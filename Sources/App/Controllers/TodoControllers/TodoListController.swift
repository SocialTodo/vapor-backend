import Vapor
import HTTP

final class TodoListController {
    typealias Model = TodoList
    
    let drop: Droplet
    let userController: FacebookUserController
    
    init(droplet: Droplet, userController facebookUserController: FacebookUserController){
        drop = droplet
        userController = facebookUserController
    }
    
    //Mark: CRUD
    
    func getTodoList() -> ResponseRepresentable {
        
    }
    
    func createTodoList() -> ResponseRepresentable {
        
    }
    
    func editTodoList() -> ResponseRepresentable {
        
    }
    
    func deleteTodoList() -> ResponseRepresentable {
        
    }
    
    func makeResource() -> Resource<TodoList> {
        return Resource()
    }
}


