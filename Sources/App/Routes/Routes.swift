import Vapor
import Foundation

extension Droplet {
    func setupRoutes() throws {
        let facebookUserController = FacebookUserController(droplet: self)
        let todoItemController = TodoItemController(droplet: self, userController: facebookUserController)
        let todoListController = TodoListController(droplet: self, userController: facebookUserController)
        
        self.get("/") { _ in return Response(status:.notFound)}
        self.post("/") { _ in return Response(status:.notFound)}
        self.options("/") { _ in return Response(status:.notFound)}
        
        //Entry point for the application
        //This should return the user's name, facebook id, user id, and the lists_id they own
        
        //return all friends with friend id, total claps and user's first and last name
        /*self.get("api/friends") {
            do {
                return try facebookUserController.getResponse($0){ user in
                    return try user.facebookFriends.all().makeNode(in: nil).converted(to: JSON.self)
                }
            } catch { return Response(status:.forbidden) }
        }*/
        
        
        //return all shared todo lists
        /*self.get("api/") {
            do {
                return try facebookUserController.getResponse($0){ user in
                    return try user.facebookFriends.all().makeResponse(using: JSONEncoder(), status: .ok)
                }
            } catch { return Response(status:.forbidden) }
        }*/
        
        self.post("api/clap") { req in
            do {
                return try facebookUserController.getResponse(req){ user in
                    guard let json = req.json else { return Response(status: .badRequest) }
                    guard let todoItemId = json["clap"]?.int else { return Response(status: .badRequest) }
                    guard let todoItem = try TodoItem.makeQuery().find(todoItemId) else { return Response(status: .badRequest) }
                    var clapped = false
                    if (try todoItem.claps.isAttached(user)) {
                        try todoItem.claps.remove(user)
                        guard let listOwner = try todoItem.parentList.get()?.listOwner.get() else { return Response(status: .internalServerError)}
                        listOwner.claps += 1
                        try listOwner.save()
                        clapped = true
                    } else {
                        try todoItem.claps.add(user)
                        guard let listOwner = try todoItem.parentList.get()?.listOwner.get() else { return Response(status: .internalServerError)}
                        listOwner.claps -= 1
                        try listOwner.save()
                    }
                    var return_json = JSON()
                    try return_json.set("clapped", clapped)
                    return try Response(status: .ok, json: return_json)
                }
            } catch { return Response(status:.forbidden) }
        }
        
        self.get("api/me") { req in
            do {
                return try facebookUserController.getResponse(req){ user in
                    var json = JSON()
                    try json.set(FacebookUser.Keys.id, user.id!)
                    try json.set(FacebookUser.Keys.name, user.name)
                    try json.set(FacebookUser.Keys.claps, user.claps)
                    try json.set("friends", user.facebookFriends.count())
                    try json.set(FacebookUser.Keys.facebookUserId, user.facebookUserId)
                    return try Response(status: .ok, json: json)
                }
            } catch { return Response(status:.forbidden) }
        }
        
        //total claps, user's first and last name and number of friends
        
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
