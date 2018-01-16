import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

class GraphApiServiceTests: XCTestCase {
    var graphApi: GraphApiService?

    override func setUp() {
        let config = try! Config(arguments: ["vapor", "--env=test"])
        do { try config.setup() } catch {}
        let drop = try! Droplet(config)
        do { try drop.setup() } catch {}

        graphApi = GraphApiService(droplet: drop)
    }

    func testFacebookLogin() {
        // Need to insert valid token and userId to work 
        do { try graphApi!.authenticate(userId: "", token: "") } catch {}
    }
}
