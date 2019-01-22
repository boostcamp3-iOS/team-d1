//
//  ViewController.swift
//  BeBrav
//
//  Created by bumslap on 22/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit
public struct Users: Codable {
    let users: [String: String]
}
public struct Name: Codable {
    let check: String = "1000원"
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var name = Name()
        DataBase.dataBase.child("root").fetchData(by: Users.self) { (result, res) in
            switch result {
            case .success(let data):
                guard let response = res as? HTTPURLResponse else {
                    return
                }
                print(response.allHeaderFields["Date"])
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }


}

