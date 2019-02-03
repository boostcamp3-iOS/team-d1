//
//  ViewController.swift
//  BeBrav
//
//  Created by bumslap on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

struct Users : Decodable {
    let users: [String: String]
}

class ExampleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let parser = JsonParser()
        let requestMaker = RequestMaker()
        
        let databaseDispatcher = Dispatcher(baseUrl: FirebaseDatabase.reference.urlComponents?.url, session: URLSession.shared)
        let databaseSeperator = NetworkSeparator(dispatcher: databaseDispatcher, requestMaker: requestMaker)
        let serverDatabase = ServerDatabase(seperator: databaseSeperator, parser: parser)
        serverDatabase.read(path: "root", type: Users.self) { (result, response) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print(data.users)
            }
        }
/*
         
         
         */
        let StorageDispatcher = Dispatcher(baseUrl: FirebaseStorage.storage.urlComponents?.url , session: URLSession.shared)
        let storageSeperator = NetworkSeparator(dispatcher: StorageDispatcher, requestMaker: requestMaker)
        let serverStorage = ServerStorage(seperator: storageSeperator, parser: parser)
        serverStorage.post(image: #imageLiteral(resourceName: "IMG_4B21E85D1553-1"), scale: 0.1, path: "artworks", fileName: "testData") { (result) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print(data)
            }
        }
/*
         
         */
        let authDispatcher = Dispatcher(baseUrl: FirebaseAuth.auth.urlComponents?.url, session: URLSession.shared)
        let authSeperator = NetworkSeparator(dispatcher: authDispatcher, requestMaker: requestMaker)
        let serverAuth = ServerAuth(seperator: authSeperator, parser: parser)
        serverAuth.signIn(email: "km9151@naver.com", password: "123456") { (result) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print(data)
            }
        }
        
        
        //factory 를 사용해서 쉽게 초기화 할 수 있습니다.
        let dependencyContainer = NetworkDependencyContainer()
        let serverDB = dependencyContainer.buildServerDatabase()
        serverDB.read(path: "root", type: Users.self) { (result, response) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print(data)
            }
        }
    }
}

