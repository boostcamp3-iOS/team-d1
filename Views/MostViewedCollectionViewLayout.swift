//
//  MostViewedCollectionViewLayout.swift
//  BeBrav
//
//  Created by bumslap on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//
//
//  MostViewedArtworkFlowLayout.swift
//  BeBrav
//
//  Created by bumslap on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class MostViewedArtworkFlowLayout: UICollectionViewFlowLayout {
    
    //weak var delegate: MostViewedArtworkDelegate!
    private var numberOfColumns = 3
    private var cellPadding: CGFloat = 2
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        get {
            guard let collectionView = collectionView else {
                return 0
            }
            let insets = collectionView.contentInset
            return collectionView.bounds.width - (insets.left + insets.right)
        }
        set {
            
        }
    }
    
    override func prepare() {
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        let leftTest = [0,3,6,9,12]
        let random = leftTest[Int.random(in: 0...4)]
        var offsetPointer = OffsetPointer(numberOfColums: 3, position: .left)
        let offsets = offsetPointer.getOffsets(count: 18, freezeAt: random)
        print(offsets.count)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            if item == random {
                frame = CGRect(x: columnWidth * CGFloat(offsets[item].0), y: columnWidth * CGFloat(offsets[item].1), width: columnWidth * 2, height: columnWidth * 2)
            } else {
                frame = CGRect(x: columnWidth * CGFloat(offsets[item].0), y: columnWidth * CGFloat(offsets[item].1), width: columnWidth, height: columnWidth)
            }
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            cache.append(attributes)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

