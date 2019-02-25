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

    struct Users : Codable {
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
    
    func testGetData() {
        let session = MockSession()
        let parser = JsonParser()
        let requestMaker = RequestMaker()
        
        let databaseDispatcher = Dispatcher(components: FirebaseDatabase.reference.urlComponents, session: session)
        let databaseSeperator = NetworkSeparator(dispatcher: databaseDispatcher, requestMaker: requestMaker)
        
        let client = ServerDatabase(seperator: databaseSeperator, parser: parser)
        client.read(path: "root/users.json", type: Users.self, headers: [:]) { (result, response) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print(data)
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
    
    func testImageSort() {
        //세로, 흑백 테스트
        var imageSort = ImageSort(input: #imageLiteral(resourceName: "angelina-litvin-37698-unsplash"))
        
        let orientation = imageSort.orientationSort()
        let color = imageSort.colorSort()
        let temperature = imageSort.temperatureSort()
        
        XCTAssert(orientation == false, "orientation sorting is failed.")
        XCTAssert(color == false, "orientation sorting is failed.")
        XCTAssert(temperature == false, "orientation sorting is failed.")
        
        //가로, 컬러, 따뜻함 테스트
        imageSort.image = #imageLiteral(resourceName: "cat2")
        
        let orientation2 = imageSort.orientationSort()
        let color2 = imageSort.colorSort()
        let temperature2 = imageSort.temperatureSort()
        
        XCTAssert(orientation2 == true, "orientation sorting is failed.")
        XCTAssert(color2 == true, "orientation sorting is failed.")
        XCTAssert(temperature2 == false, "orientation sorting is failed.")
        
        //차가움 테스트
        imageSort.image = #imageLiteral(resourceName: "bruce-christianson-559084-unsplash")
        
        let orientation3 = imageSort.orientationSort()
        let color3 = imageSort.colorSort()
        let temperature3 = imageSort.temperatureSort()
        
        XCTAssert(orientation3 == true, "orientation sorting is failed.")
        XCTAssert(color3 == true, "orientation sorting is failed.")
        XCTAssert(temperature3 == true, "orientation sorting is failed.")
    }
}
