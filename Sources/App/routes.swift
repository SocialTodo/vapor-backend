import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
    let facebookUserController = FacebookUserController(droplet: self)
    let todoItemController = TodoItemController(droplet: self, userController: facebookUserController)
    let todoListController = TodoListController(droplet: self, userController: facebookUserController)
    
    router.get("/") { _ in return Response(status:.notFound)}
    router.post("/") { _ in return Response(status:.notFound)}
    router.options("/") { _ in return Response(status:.notFound)}
    
    self.resource("api/users", facebookUserController)
    
    router.get("api/users", use: facebookUserController.)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
    
    //List Manager
    //A GET should return the todoItems the user is interested in seeing
    //A POST to root should create a new list
    //A POST to a list id should create a new todo item in the context of that list, and return it's list_id
    //A PATCH should change the list's name
    //A DELETE should remove a list AND it's items
    
    self.resource("api/list", todoListController)
    
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
    
    //TodoItem Manager
    //A GET should return a todoItem the user is interested in seeing
    //A PATCH should change the todoList item
    //A DELETE should remove a todoList item
    
    self.resource("api/item", todoItemController)
    
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}

