import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

class FacebookModelTests: XCTestCase {
    var users: [FacebookUser] = []
    var facebookUserController: FacebookUserController!
    
    override func setUp() {
        let config = try! Config(arguments: ["vapor", "--env=test"])
        do { try config.setup() } catch {}
        let drop = try! Droplet(config)
        do { try drop.setup() } catch {}
        
        facebookUserController = FacebookUserController(droplet:drop)
        
        let test_users = [
        ["name": "Alondra Krause", "id": 6316816636194673], ["name": "Eliana Cordova", "id": 2467825702628370], ["name": "Tori Howell", "id": 1117789108273389],
        ["name": "Rey Dickson", "id": 2418890580099085], ["name": "Phoenix Andrews", "id": 9163667750244648], ["name": "Talon Farmer", "id": 2999009655073479],
        ["name": "Carolina Cortez", "id": 9038707755843264], ["name": "Penelope Velazquez", "id": 6991266520965726], ["name": "Giancarlo Manning", "id": 2749147975847501],
        ["name": "Camron Oliver", "id": 3707558171063215], ["name": "Moriah Cross", "id": 4588976795742594]
        ]
        
        test_users.forEach{users.append(FacebookUser(userId: $0["id"] as! Int, token: "12345", name: $0["name"] as! String))}
        do { try users.forEach{ try $0.save() } } catch { print("ERROR SAVING MODEL")}
    }
    
    func testGetCachedUser() {
        do {
            let expectedUser = try facebookUserController.authenticate(userId: 6316816636194673, token: "12345")
            XCTAssert(expectedUser?.name == "Alondra Krause")
        } catch {
            XCTAssert(false)
        }
    }
    
    func testFailToGetCachedUser() {
        do {
            let expectedNilUser = try facebookUserController.authenticate(userId: 6316816636194673, token: "")
            XCTAssert(expectedNilUser == nil)
        } catch {
            XCTAssert(false)
        }
    }
    
}
