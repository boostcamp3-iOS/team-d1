//
//  ServerDatabaseTest.swift
//  BeBravUnitTests
//
//  Created by bumslap on 17/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import XCTest
@testable import BeBrav

class ServerDatabaseTest: XCTestCase {
    var resultData: Data? = nil
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
    
    func testMakeRequest() {
        //given
        let requestMaker = RequestMaker()
        guard let components = FirebaseDatabase.reference.urlComponents else {
            return
        }
        var url = components.url
        url?.appendPathComponent("root/users.json")

        let request = requestMaker.makeRequest(url: url,
                                               method: .get,
                                               headers: ["Content-Type": "application/json"],
                                               body: nil)
        let expectedURL = "https://bravyprototype.firebaseio.com/root/users.json"
        let actualURL = request?.url?.absoluteString
        XCTAssertEqual(expectedURL, actualURL!)
        
        let expectedMethod = HTTPMethod.get
        let actualMethod = request?.httpMethod
        XCTAssertEqual(actualMethod, expectedMethod.rawValue)
    }
    
    ///isSuccess때문에 fail 함
    func testAPIServiceDispatch() {
        
        //given
        let requestMaker = RequestMaker()
        guard let components = FirebaseDatabase.reference.urlComponents else {
            return
        }
        var url = components.url
        url?.appendPathComponent("root/users.json")
        
        let request = requestMaker.makeRequest(url: url,
                                               method: .get,
                                               headers: ["Content-Type": "application/json"],
                                               body: nil)
        let session = MockSession()
        let dispatcher = Dispatcher(components: components, session: session)
        
        //when
        dispatcher.dispatch(request: request!) { (result, response) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                self.resultData = data
            }
        }
        
        //then
        let pred = NSPredicate(format: "resultData != nil")
        let exp = expectation(for: pred, evaluatedWith: self, handler: nil)
        let res = XCTWaiter.wait(for: [exp], timeout: 5.0)
        if res == XCTWaiter.Result.completed {
            XCTAssertNotNil(resultData, "No data recived from the server for InfoView content")
        } else {
            XCTAssert(false, "The call to get the URL ran into some other error")
        }
    }
        
        
        
        
    func testNetworkSeperatorRead() {
        //given
        guard let components = FirebaseDatabase.reference.urlComponents else {
            return
        }
        //var url = components.url
        //url?.appendPathComponent("root/users.json")
        
        let session = MockSession()
        let dispatcher = Dispatcher(components: components, session: session)
        let requestMaker = RequestMaker()
        let readSeperator = NetworkSeparator(dispatcher: dispatcher, requestMaker: requestMaker)
        
        //when
        readSeperator.read(path: "root/users", queries: nil) { (result, response) in
            switch result {
            case .failure:
                print("failed")
            case .success(let data):
                self.resultData = data
            }
        }
        
        //then
        let pred = NSPredicate(format: "resultData != nil")
        let exp = expectation(for: pred, evaluatedWith: self, handler: nil)
        let res = XCTWaiter.wait(for: [exp], timeout: 5.0)
        if res == XCTWaiter.Result.completed {
            XCTAssertNotNil(resultData, "No data recived from the server for InfoView content")
        } else {
            XCTAssert(false, "The call to get the URL ran into some other error")
        }
    }
        
    func testNetworkSeperatorWrite() {
            
    }
        
    func testNetworkSeperatorDelete() {
            
    }
}
    
    
    
    /*
// given
let sessionManager = SessionManagerStub()
let service = RepositoryService(sessionManager: sessionManager)

// when
service.search(keyword: "RxSwift", completionHandler: { _ in })

// then
let expectedURL = "https://api.github.com/search/repositories"
let actualURL = try? sessionManager.requestParameters?.url.asURL().absoluteString
XCTAssertEqual(actualURL, expectedURL)

let expectedMethod = HTTPMethod.get
let actualMethod = sessionManager.requestParameters?.method
XCTAssertEqual(actualMethod, expectedMethod)

let expectedParameters = ["q": "RxSwift"]
let actualParameters = sessionManager.requestParameters?.parameters as? [String: String]
XCTAssertEqual(actualParameters, expectedParameters)
}*/


