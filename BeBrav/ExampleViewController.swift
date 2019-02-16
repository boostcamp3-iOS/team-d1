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

/*struct UserData : Encodable {
    let users: [String: [String: String]]
}*/

class ExampleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let parser = JsonParser()
        let requestMaker = RequestMaker()
        
        let databaseDispatcher = Dispatcher(components: FirebaseDatabase.reference.urlComponents, session: URLSession.shared)
        let databaseSeperator = NetworkSeparator(dispatcher: databaseDispatcher, requestMaker: requestMaker)
        let serverDatabase = ServerDatabase(seperator: databaseSeperator, parser: parser)
        //let userData = UserData(uid: uid, nickName: "12", email: email, userProfileUrl: "123", artworks: "hhhh")
       /* serverDatabase.write(path: "root", data: userData, method: <#T##HTTPMethod#>, completion: <#T##(Result<Data>, URLResponse?) -> Void#>)(path: "root", type: Users.self) { (result, response) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print(data.users)
            }
        }*/
/*
         
         
         */
        let StorageDispatcher = Dispatcher(components: FirebaseStorage.storage.urlComponents , session: URLSession.shared)
        let storageSeperator = NetworkSeparator(dispatcher: StorageDispatcher, requestMaker: requestMaker)
        let serverStorage = ServerStorage(seperator: storageSeperator, parser: parser)
       /* serverStorage.post(image: #imageLiteral(resourceName: "cat2"), scale: 0.1, path: "artworks", fileName: "testing") { (result, res) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print(data)
            }
        }*/
    
/*
         
         */
        
        let authDispatcher = Dispatcher(components: FirebaseAuth.auth.urlComponents, session: URLSession.shared)
        let authSeperator = NetworkSeparator(dispatcher: authDispatcher, requestMaker: requestMaker)
        let serverAuth = ServerAuth(seperator: authSeperator, parser: parser)
        serverAuth.signUp(email: "kj9151@naver.com", password: "123456") { (result) in
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
        
        //let userDataWithTimestamp =
           // UserData(users: ["timestamp" : [".sv": "timestamp"]])
        /*serverDB.write(path: "root", data: userDataWithTimestamp, method: .post) {
            (result, response) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                let extractedData = parser.extractDecodedJsonData(decodeType: [String: String].self, binaryData: data)
                print(extractedData)
            }
        }*/
        /*serverDB.read(path: "root", type: Users.self) { (result, response) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print(data)
            }
        }*/
        
       
        let serverDB = dependencyContainer.buildServerDatabase()
        let serverST = dependencyContainer.buildServerStorage()
        let serverAu = dependencyContainer.buildServerAuth()
        
        let manager = ServerManager(authManager: serverAu,
                                    databaseManager: serverDB,
                                    storageManager: serverST,
                                    uid: "123")
        /* 초기 설정시 동기화를 위해서 사용 */
 /*
        manager.signUp(email: "t1@naver.com", password: "123456") { (result) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                manager.signIn(email: "t1@naver.com", password: "123456") { (result) in
                    switch result {
                    case .failure(let error):
                        print(error)
                        return
                    case .success(let data):
                        manager.uploadArtwork(image: #imageLiteral(resourceName: "cat1"), scale: 0.1, path: "artworks", fileName: "TestImage1") { (result) in
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
            }
        }
 */
        /*
        
        manager.signIn(email: "t1@naver.com", password: "123456") { (result) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print("success")
                for i in 0...100 {
                    let image = self.imageAssets[Int.random(in: 0..<23)]
                    manager.uploadArtwork(image: image, scale: 0.1, path: "artworks", fileName: "test\(i)") { (result) in
                        switch result {
                        case .failure(let error):
                            print(error)
                            return
                        case .success(let data):
                            print("success")
                        }
                    }
                    
                }
            }
        }
        */
    }
}

