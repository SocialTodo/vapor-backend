import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

class GraphApiServiceTests: XCTestCase {
    var graphApi: GraphApiService!
    var testFacebookUserId: Int!
    var testFacebookToken: String!
    var testFacebookName: String!

    override func setUp() {
        let config = try! Config(arguments: ["vapor", "--env=test"])
        do { try config.setup() } catch {}
        let drop = try! Droplet(config)
        do { try drop.setup() } catch {}
        
        testFacebookUserId = Int(ProcessInfo.processInfo.environment["TEST_FACEBOOK_USER_ID"]!)
        testFacebookToken = ProcessInfo.processInfo.environment["TEST_FACEBOOK_TOKEN"]
        testFacebookName = ProcessInfo.processInfo.environment["TEST_FACEBOOK_NAME"]
        

        graphApi = GraphApiService(droplet: drop)
    }

    func testFacebookLogin() {
        // Need to insert valid token and userId to work 
        let result = graphApi.authenticate(userId: testFacebookUserId, token: testFacebookToken)!
        XCTAssert(result.valid == true && result.facebookUserId == testFacebookUserId && result.expiration != nil )
    }

    func testGetUserProfileSome() {
        let result = graphApi.userProfile(userId: testFacebookUserId, token: testFacebookToken)!
        XCTAssert(result.facebookUserId == testFacebookUserId && result.facebookName == testFacebookName)
    }
}
