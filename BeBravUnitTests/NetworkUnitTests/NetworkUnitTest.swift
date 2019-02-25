//
//  NetworkUnitTest.swift
//  BeBravUnitTests
//
//  Created by bumslap on 25/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import XCTest
@testable import BeBrav

class NetworkUnitTest: XCTestCase {
    
    var resultData: Data!
    var serverDatabaseResult: [String: ArtworkDecodeType]!
    var session: URLSessionProtocol!
    var requestMaker: RequestMakable!
    var jsonParser: ResponseParser!
    
    override func setUp() {
        self.resultData = nil
        self.serverDatabaseResult = nil
        self.session = MockSession()
        self.requestMaker = RequestMaker()
        self.jsonParser = JsonParser()
    }

    override func tearDown() { }

    func testPerformanceExample() {
        
        self.measure { }
    }
    
    
    func testMakeRequest() {
        //given
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
    
    func testAPIServiceDispatch() {
        
        //given
        guard let components = FirebaseDatabase.reference.urlComponents else {
            return
        }
        var url = components.url
        url?.appendPathComponent("root/users.json")
        
        let request = requestMaker.makeRequest(url: url,
                                               method: .get,
                                               headers: ["Content-Type": "application/json"],
                                               body: nil)
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
    
    func testServerDatabaseRead() {
        
        //given
        guard let components = FirebaseDatabase.reference.urlComponents else {
            return
        }
        var isRequestSuccess = false
        let mockParser = MockJsonParser()
        let dispatcher = Dispatcher(components: components, session: session)
        let seperator = NetworkSeparator(dispatcher: dispatcher, requestMaker: requestMaker)
        let serverDatabase = ServerDatabase(seperator: seperator, parser: mockParser)
        
        //when
        serverDatabase.read(path: "root/artworks", type: [String: ArtworkDecodeType].self, headers: [:]) { (result, response) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                isRequestSuccess = true
            }
        }
        
        //then
        let pred = NSPredicate(format: "serverDatabaseResult != nil")
        let exp = expectation(for: pred, evaluatedWith: self, handler: nil)
        let res = XCTWaiter.wait(for: [exp], timeout: 5.0)
        if res == XCTWaiter.Result.completed {
            XCTAssertNotNil(serverDatabaseResult, "No data recived from the server for InfoView content")
        } else {
            XCTAssert(false, "The call to get the URL ran into some other error")
        }
    }
    
    
    
}


