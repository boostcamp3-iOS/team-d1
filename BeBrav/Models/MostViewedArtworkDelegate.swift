//
//  MostViewedArtworkDelegate.swift
//  BeBrav
//
//  Created by bumslap on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

protocol MostViewedArtworkDelegate: class {
     func collectionView(_ collectionView:UICollectionView, mostViewedArtworkIndexPath indexPath:IndexPath) -> Bool
}
