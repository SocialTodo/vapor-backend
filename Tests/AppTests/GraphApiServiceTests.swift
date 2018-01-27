import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

class GraphApiServiceTests: XCTestCase {
    var drop: Droplet!
    var testFacebookUserId: Int!
    var testFacebookToken: String!
    var testFacebookName: String!

    override func setUp() {
        let config = try! Config(arguments: ["vapor", "--env=test"])
        do { try config.setup() } catch {}
        drop = try! Droplet(config)
        do { try drop.setup() } catch {}
        
        testFacebookUserId = Int(ProcessInfo.processInfo.environment["TEST_FACEBOOK_USER_ID"]!)
        testFacebookToken = ProcessInfo.processInfo.environment["TEST_FACEBOOK_TOKEN"]
        testFacebookName = ProcessInfo.processInfo.environment["TEST_FACEBOOK_NAME"]
    }

    func testFacebookLogin() {
        // Need to insert valid token and userId to work 
        let result = drop.authenticate(userId: testFacebookUserId, token: testFacebookToken)!
        XCTAssert(result.valid == true && result.facebookUserId == testFacebookUserId && result.expiration != nil )
    }

    func testGetUserProfileSome() {
        let result = drop.userProfile(userId: testFacebookUserId, token: testFacebookToken)!
        XCTAssert(result.facebookUserId == testFacebookUserId && result.facebookName == testFacebookName)
    }
}
