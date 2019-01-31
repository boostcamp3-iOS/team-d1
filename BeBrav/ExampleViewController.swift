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
        
        var datastorage = ServerStorage(session: URLSession.shared)
        datastorage.addPath("artworks")
        datastorage.uploadImage(image: #imageLiteral(resourceName: "cat1"), scale: 0.1, fileName: "catImage2") { (result) in
            switch result {
            case .failure:
                return
            case .success:
                print(result)
            }
        }
        
        var datastorage2 = ServerStorage(session: URLSession.shared)
        datastorage2.addPath("artworks")
        datastorage2.fetchDownloadUrl(fileName: "catImage2"){ (result) in
            switch result {
            case .failure:
                return
            case .success:
                print(result)
            }
        }
        

        ServerAuth(session: URLSession.shared).signInUser(email: "ki9151@naver.com", password: "123456") { (result) in
            switch result {
            case .failure:
                return
            case .success(let res):
                guard let response = res as? HTTPURLResponse else {return}
                print(response.allHeaderFields)
                print("success")
            }
        }
        
        var database = ServerDataBase(session: URLSession.shared)
        database.addPath("root")
        database.fetchData(by: Users.self) { (result, res) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let data):
                print(data.users)
            }
        }
    }
   
}

