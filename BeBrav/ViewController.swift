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

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ServerDataBase(session: URLSession.shared).child("root").fetchData(by: Users.self) { (result, res) in
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
        }
    }
}

