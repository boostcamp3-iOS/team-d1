//  MostViewedArtworkFlowLayout.swift
//  BeBrav
//
//  Created by bumslap on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// MostViewedArtworkFlowLayout은 UICollectionViewFlowLayout을 상속받아서 만든 Custom Layout 입니다
/// 데이터가 fetch될 떄마다 바뀌는 bounds를 이용하여 prepare() 메서드를 호출하게 만들고 그안에 cache 에 레이아웃을 계속
/// 추가하여 필요한만큼 레이아웃을 만들어 내는 역할을 합니다.
import UIKit

class MostViewedArtworkFlowLayout: UICollectionViewFlowLayout {
    
    ///MostViewLayoutDelegate 타입의 프로퍼티로 현재 만드려는 레이아웃(한 페이지)에서 어떤 데이터가
    ///가장 많은 뷰 수를 가지는지를 물어보기 위해 만든 프로퍼티입니다.
    weak var delegate: MostViewLayoutDelegate!
    
    ///pageNuber 프로퍼티는 Controller 측에서 페이지를 업로드 할때마다 값을 늘려서 전달해주어야 하기때문에 internal 입니다.
    var pageNumber = 0
    ///numberOfItems 프로퍼티는 Controller 측에서 width를 계산한 이후에 전달해 주어야합니다.
    var numberOfItems = 0
    ///한 페이지에 해당하는 offset을 전부 저장합니다.
    var offsetBucket: [(CGFloat, CGFloat)] = []
    
    
    private var latestOrientation: Orientation = .portrait
    ///레이아웃의 기본설정을 맡는 프로퍼티입니다.
    private var numberOfColumns = 3
    private var cellPadding: CGFloat = 2
    
    ///레이아웃을 UICollectionViewLayoutAttributes로 만들어 놓고 저장해두는 cache 입니다.
    private var cache = [UICollectionViewLayoutAttributes]()
    
    ///현재 뷰의 width를 계산하는 computed 프로퍼티 입니다.
    private var contentWidth: CGFloat {
        get {
            guard let collectionView = collectionView else {
                return 0
            }
            let insets = collectionView.contentInset
            return collectionView.bounds.width - (insets.left + insets.right)
        }
    }
    
    private var contentHeight: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    /// UICollectionViewFlowLayout의 prepare() 메서드를 override하였습니다. 이 메서드는 bounds가 변경되면 불리게 됩니다.
    /// 내부 동작방식:
    /// 먼저 column의 갯수로 contentWidth 로 나누어 각 셀당 얼마의 width를 가져야 할 지 계산합니다. 이후 delegate를 통해서
    /// 요청한 한 페이지 중 가장 뷰 수가 많은 데이터의 인덱스를 요청합니다. 이를 기반으로 OffsetPointer 인스탠스를 만들게 되고
    /// 리턴된 offset을 offsetBucket에 넣어 저장합니다. 이후 루프를 돌면서 (pageNumber * numberOfItems)를 이용하여 요청된
    /// 페이지에 해당하는 부분의 UICollectionViewLayoutAttributes를 생성한 후 이를 cache에 저장합니다.
    override func prepare() {
        
        guard let collectionView = collectionView,
            collectionView.numberOfItems(inSection: 0) != 0 else {
                return
        }
        
        var currentOrientation: Orientation = .portrait
        
        if collectionView.frame.width > collectionView.frame.height {
            currentOrientation = .landScape
        } else {
            currentOrientation = .portrait
        }
        
        if currentOrientation == latestOrientation {
            
        } else {
            
        }
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        let index = delegate.getCurrentMostViewedArtworkIndex()
        let rowHeight = numberOfItems / numberOfColumns + 1
        
        
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        var offsetPointer = OffsetPointer(numberOfColums: numberOfColumns,
                                          yOffset: pageNumber * rowHeight)
        let offsets = offsetPointer.getOffsets(count: numberOfItems + 3, freezeAt: index)
        print("offset count\(offsets.count)")
            for offset in offsets {
                offsetBucket.append(offset)
            }
        
            for item in (pageNumber * numberOfItems) ..< collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                if item == (index + (pageNumber * numberOfItems)) {
                    frame = CGRect(x: columnWidth * CGFloat(offsetBucket[item].0),
                                   y: columnWidth * CGFloat(offsetBucket[item].1),
                                   width: columnWidth * 2,
                                   height: columnWidth * 2)
                } else {
                    frame = CGRect(x: columnWidth * CGFloat(offsetBucket[item].0),
                                   y: columnWidth * CGFloat(offsetBucket[item].1),
                                   width: columnWidth,
                                   height: columnWidth)
                }
                
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                print("attr\(attributes.frame)")
                cache.append(attributes)
            }
        contentHeight = cache.last?.frame.maxY ?? 0.0
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
    
    func invalidateCache() {
        cache.removeAll()
        
    }
    
    override func invalidateLayout() {
        guard let collectionView = collectionView,
            collectionView.numberOfItems(inSection: 0) != 0 else {
                return
        }
        if collectionView.frame.width > collectionView.frame.height {
            latestOrientation = .landScape
        } else {
            latestOrientation = .portrait
        }
        super.invalidateLayout()
    }
}

enum Orientation {
    case portrait
    case landScape
}
