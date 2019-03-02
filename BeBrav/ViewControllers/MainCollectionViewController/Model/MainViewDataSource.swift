//
//  MainViewDataSource.swift
//  BeBrav
//
//  Created by bumslap on 01/03/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class MainViewDataSource: NSObject, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     return .init()
    }
}
