//
//  BeBravUnitTests.swift
//  BeBravUnitTests
//
//  Created by bumslap on 25/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import XCTest
@testable import BeBrav
class BeBravUnitTests: XCTestCase {

    struct Users : Decodable {
        let users: [String: String]
    }
    var resData: [String: String] = [:]
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFetchData() {
        let session = MockSession()
        let client = ServerDataBase(session: session)
        client.fetchData(by: Users.self) { (result, res) in
            switch result {
            case .failure:
                return
            case .success(let data):
                self.resData = data.users
            }
        }
        let pred = NSPredicate(format: "resData != nil")
        let exp = expectation(for: pred, evaluatedWith: self, handler: nil)
        let res = XCTWaiter.wait(for: [exp], timeout: 5.0)
        if res == XCTWaiter.Result.completed {
            XCTAssertNotNil(resData, "No data recived from the server for InfoView content")
        } else {
            XCTAssert(false, "The call to get the URL ran into some other error")
        }
        
    }

}
