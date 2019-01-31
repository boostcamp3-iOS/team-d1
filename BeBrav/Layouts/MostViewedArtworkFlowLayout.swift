//
//  MostViewedArtworkFlowLayout.swift
//  BeBrav
//
//  Created by bumslap on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class MostViewedArtworkFlowLayout: UICollectionViewFlowLayout {
    
    weak var delegate: MostViewedArtworkDelegate!
    private var isOnce = true //TODO: Test용 나중에 델리게이트로 대체
    private var numberOfColumns = 3
    private var cellPadding: CGFloat = 2
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        var yOffset = [CGFloat]()
        xOffset.append(columnWidth * 0)
        xOffset.append(columnWidth * 2)
        xOffset.append(columnWidth * 2)
        xOffset.append(columnWidth * 0)
        xOffset.append(columnWidth * 1)
        xOffset.append(columnWidth * 2)
        xOffset.append(columnWidth * 0)
        xOffset.append(columnWidth * 1)
        xOffset.append(columnWidth * 2)
        xOffset.append(columnWidth * 0)
        xOffset.append(columnWidth * 1)
        xOffset.append(columnWidth * 2)
        xOffset.append(columnWidth * 0)
        xOffset.append(columnWidth * 1)
        xOffset.append(columnWidth * 2)
        xOffset.append(columnWidth * 0)
        xOffset.append(columnWidth * 1)
        xOffset.append(columnWidth * 2)
        
        yOffset.append(columnWidth * 0)
        yOffset.append(columnWidth * 0)
        yOffset.append(columnWidth * 1)
        yOffset.append(columnWidth * 2)
        yOffset.append(columnWidth * 2)
        yOffset.append(columnWidth * 2)
        yOffset.append(columnWidth * 3)
        yOffset.append(columnWidth * 3)
        yOffset.append(columnWidth * 3)
        yOffset.append(columnWidth * 4)
        yOffset.append(columnWidth * 4)
        yOffset.append(columnWidth * 4)
        yOffset.append(columnWidth * 5)
        yOffset.append(columnWidth * 5)
        yOffset.append(columnWidth * 5)
        yOffset.append(columnWidth * 6)
        yOffset.append(columnWidth * 6)
        yOffset.append(columnWidth * 6)
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            if isOnce {
                frame = CGRect(x: xOffset[item], y: yOffset[item], width: columnWidth * 2, height: columnWidth * 2)
                isOnce = false
            } else {
                frame = CGRect(x: xOffset[item], y: yOffset[item], width: columnWidth, height: columnWidth)
            }
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            contentHeight = max(contentHeight, frame.maxY)
        }
        //TODO: 알고리즘 구현부
        
        /*for column in 0..<numberOfColumns {
            if isOnce {
                xOffset.append(CGFloat(column) * columnWidth * 2)
            } else {
                
            }
        }*/
        
        
        /*
        for column in 0 ..< numberOfColumns {
            if !isOnce {
                xOffset.append(CGFloat(column) * columnWidth * 2)
                continue
            }
            xOffset.append(CGFloat(column) * columnWidth)
            print(xOffset)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
 
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
 
            let photoHeight = delegate.collectionView(collectionView, mostViewedArtworkIndexPath: indexPath)
            //let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: columnWidth)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
 
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
 
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + cellPadding * 2 +
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }*/
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
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
