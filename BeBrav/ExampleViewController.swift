//
//  ViewController.swift
//  BeBrav
//
//  Created by bumslap on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

struct Users : Codable {
    let users: [String: String]
}

class ExampleViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       /* ServerDataBase(session: URLSession.shared).child("root").fetchData(by: Users.self) { (result, res) in
            switch result {
            case .failure:
                return
            case .success:
                print(result)
            }
        }
        ServerDataBase(session: URLSession.shared).child("root").setData(data: Users(users: ["bum": "himan"])) { (result) in
            switch result {
            case .failure:
                return
            case .success:
                print(result)
            }
        }
        */
        /*ServerAuth(session: URLSession.shared).signUpUser(email: "ki9151@naver.com", password: "123456") { (result) in
            switch result {
            case .failure:
                return
            case .success(let res):
                guard let response = res as? HTTPURLResponse else {return}
                print(response.allHeaderFields)
            }
        }*/
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
       /* ServerDataBase(session: URLSession.shared).child("root").fetchData(by: Users.self) { (result, res) in
            switch result {
            case .failure:
                return
            case .success:
                print(result)
            }
        }
        ServerDataBase(session: URLSession.shared).child("root").deleteData() { (result) in
            switch result {
            case .failure:
                return
            case .success:
                print(result)
            }
        }
        
        ServerStorage(session: URLSession.shared).child("artworks").uploadImage(image: #imageLiteral(resourceName: "cat1"), scale: 0.1, fileName: "catImage") { (result) in
            switch result {
            case .failure:
                return
            case .success:
                print(result)
            }
        }
        
        ServerStorage(session: URLSession.shared).child("artworks").fetchDownloadUrl(fileName: "catImage") { (result) in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success:
                print(result)
            }
        }*/
       //
        
        print(Auth.signUp.urlComponents.url)
    }
}

