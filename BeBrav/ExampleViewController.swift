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
    let imageAssets = [#imageLiteral(resourceName: "StockSnap_KK9KNIXXOR"),#imageLiteral(resourceName: "open-fire-3879031_1920"),#imageLiteral(resourceName: "angel-2403401_1920"),#imageLiteral(resourceName: "close-up-desk-indoors-1459102"),#imageLiteral(resourceName: "lion-3372720_1920"),#imageLiteral(resourceName: "orlova-maria-375371-unsplash"),#imageLiteral(resourceName: "evolution-3801547_1920"),#imageLiteral(resourceName: "stefania-crudeli-1074566-unsplash"),#imageLiteral(resourceName: "cat1"),#imageLiteral(resourceName: "helicopter-2966569_1920"),#imageLiteral(resourceName: "photographer"),#imageLiteral(resourceName: "am-fl-1326209-unsplash"),#imageLiteral(resourceName: "hamburg"),#imageLiteral(resourceName: "delicious-drink-drinking-glass-1474926"),#imageLiteral(resourceName: "firenze-1249854_1920"),#imageLiteral(resourceName: "997077465A73DC122B"),#imageLiteral(resourceName: "christmas-motif-3834860_1920"),#imageLiteral(resourceName: "beer-2161767_1920"),#imageLiteral(resourceName: "breakfast-chocolate-cloth-1740890"),#imageLiteral(resourceName: "99E4A0485A73DAB318"),#imageLiteral(resourceName: "harley-davidson-3794909_1920"),#imageLiteral(resourceName: "light-bulb-3903345_1920"),#imageLiteral(resourceName: "bowls-breakfast-cutlery-1813503"),#imageLiteral(resourceName: "StockSnap_DLMN8FFBD9"),#imageLiteral(resourceName: "tet-3979500_1920"),#imageLiteral(resourceName: "StockSnap_P5M4OGVMEP"),#imageLiteral(resourceName: "beverage-breakfast-caffeine-1879321"),#imageLiteral(resourceName: "cat2"),#imageLiteral(resourceName: "old-man-2687112_1920"),#imageLiteral(resourceName: "wolf-3818343_1920"),#imageLiteral(resourceName: "painting-1974614_1920"),#imageLiteral(resourceName: "statue-of-liberty-267949_1920"),#imageLiteral(resourceName: "chairs-comfort-contemporary-1813502"),#imageLiteral(resourceName: "old-3975765_1920"),#imageLiteral(resourceName: "people-3968216_1920"),#imageLiteral(resourceName: "polar-bear-196318_1920"),#imageLiteral(resourceName: "taxi-cab-381233_1920"),#imageLiteral(resourceName: "flower-3844639_1920"),#imageLiteral(resourceName: "얼룩말"),#imageLiteral(resourceName: "blur-close-up-container-1740904"),#imageLiteral(resourceName: "north"),#imageLiteral(resourceName: "adorable-animal-cat-1477377"),#imageLiteral(resourceName: "adorable-animal-cat-1741206"),#imageLiteral(resourceName: "smoke-69124_1280"),#imageLiteral(resourceName: "breakfast-cutlery-decoration-1458680"),#imageLiteral(resourceName: "landscape-3779159_1920"),#imageLiteral(resourceName: "art-1478831_1920"),#imageLiteral(resourceName: "4k-wallpaper-beautiful-bloom-1460799"),#imageLiteral(resourceName: "meteora-3717220_1920"),#imageLiteral(resourceName: "agenda-3981505_1920"),#imageLiteral(resourceName: "chair-cup-of-coffee-desk-1459103"),#imageLiteral(resourceName: "StockSnap_51MWB7SI71"),#imageLiteral(resourceName: "wallaby-3764309_1920"),#imageLiteral(resourceName: "sea-3974262_1920"),#imageLiteral(resourceName: "flower-3980666_1920"),#imageLiteral(resourceName: "close-up-cup-of-coffee-desk-1459104"),#imageLiteral(resourceName: "fallow-deer-3729821_1920"),#imageLiteral(resourceName: "full-moon-496873_1920"),#imageLiteral(resourceName: "mosaic-200864_1920"),#imageLiteral(resourceName: "beverage-books-coffee-1638502")]
    
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
        
        //dummy image 60장 upload
        manager.signIn(email: "t1@naver.com", password: "123456") { (result) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print("success")
                for i in 0...59 {
                    let image = self.imageAssets[i]
                    manager.uploadArtwork(image: image, scale: 0.1, path: "artworks", fileName: "test\(i)", completion: { (result) in
                        switch result {
                        case .failure(let error):
                            print(error)
                            return
                        case .success(let data):
                            print("success")
                        }
                    })
                }
            }
        }
        
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

