import Vapor

extension Droplet {
    func setupRoutes() throws {
        let facebookUserController = FacebookUserController(droplet: self)
        let todoItemController = TodoItemController(droplet: self, userController: facebookUserController)
        let todoListController = TodoListController(droplet: self, userController: facebookUserController)
        
        //Entry point for the application
        //This should return the user's name, facebook id, user id, and the lists_id they own
        
        self.resource("api/users", facebookUserController)
        
        //List Manager
        //A GET should return the todoItems the user is interested in seeing
        //A POST to root should create a new list
        //A POST to a list id should create a new todo item in the context of that list, and return it's list_id
        //A PATCH should change the list's name
        //A DELETE should remove a list AND it's items

        self.resource("api/list", todoListController)
        
        //TodoItem Manager
        //A GET should return a todoItem the user is interested in seeing
        //A PATCH should change the todoList item
        //A DELETE should remove a todoList item
        
        self.resource("api/item", todoItemController)
    }
    //Make primary key chagne
}
