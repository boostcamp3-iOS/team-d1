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
   
    var prepareIndex: [Int] = []
    
    var fetchPage = 0
    ///pageNumber 프로퍼티는 Controller 측에서 페이지를 업로드 할때마다 값을 내부적으로 증가시킵니다.
    private var pageNumber = 0
    ///numberOfItems 프로퍼티는 Controller 측에서 width를 계산한 이후에 전달해 주어야합니다.
    var numberOfItems = 0
    ///한 페이지에 해당하는 offset을 전부 저장합니다.
    var offsetBucket: [(CGFloat, CGFloat)] = []
    
    ///레이아웃의 기본설정을 맡는 프로퍼티입니다.
    private var numberOfColumns = 3
    private var cellPadding: CGFloat = 2
    
    ///레이아웃을 UICollectionViewLayoutAttributes로 만들어 놓고 저장해두는 cache 입니다.
    private var cache: [UICollectionViewLayoutAttributes] = []
    
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
        let lastBiggestYItem = cache.suffix(numberOfColumns).max()
        contentHeight = max(contentHeight, lastBiggestYItem?.frame.maxY ?? 0.0)
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override init() {
        super.init()
        self.sectionFootersPinToVisibleBounds = true
        self.footerReferenceSize = CGSize(width: 300, height: 60)
        //self.footerReferenceSize = CGSize(width: 300, height: 100)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      
    }
    
    /// UICollectionViewFlowLayout의 prepare() 메서드를 override하였습니다. 이 메서드는 bounds가 변경되면 불리게 됩니다.
    /// 내부 동작방식:
    /// 미리 받아온 prepareIndex로 makeAttributes() 메서드를 실행합니다. 첫번째에서만 실행하기 때문에 이후 해당 배열을
    /// 지워주게 됩니다.
    override func prepare() {
        super.prepare()
        
        if prepareIndex.isEmpty {
            return
        }
        
        makeAttributes(indexList: prepareIndex, pageSize: fetchPage)
        prepareIndex.removeAll()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
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

extension UICollectionViewLayoutAttributes: Comparable {
    public static func < (lhs: UICollectionViewLayoutAttributes, rhs: UICollectionViewLayoutAttributes) -> Bool {
        return lhs.frame.maxY < rhs.frame.maxY
    }
}

extension MostViewedArtworkFlowLayout: PagingControlDelegate {
    
    func layoutRefresh() {
        prepareIndex.removeAll()
        fetchPage = 0
        pageNumber = 0
        offsetBucket.removeAll()
        cache.removeAll()
    }
    
    /// PagingControlDelegate 의 구현 메서드 입니다. PaginationCollectionViewController에서 호출하게 됩니다.
    ///
    /// - Parameters:
    ///   - indexList: 빅사이즈 셀의 index를 담아놓은 배열입니다.
    ///   - pageSize: 한번에 받아올 batchSize를 의미합니다.
    /// - Returns:
    func constructNextLayout(indexList: [Int], pageSize: Int) {
            makeAttributes(indexList: indexList, pageSize: pageSize)
    }
    
    /// makeAttributes() 메서드는 빅사이즈 셀에 대한 정보와 batchSize를 받아서 해당하는 Attributes를
    /// 생성해주는 메서드입니다.
    ///
    /// - Parameters:
    ///   - indexList: 빅사이즈 셀의 index를 담아놓은 배열입니다.
    ///   - pageSize: 한번에 받아올 batchSize를 의미합니다.
    /// - Returns: cache에 Attributes를 담고 contentHeight를 업데이트합니다.
    private func makeAttributes(indexList: [Int], pageSize: Int) {
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        let rowHeight = numberOfItems / numberOfColumns + 1
        var inspectableRange = 0..<0
        var yOffset = pageNumber
        
        indexList.forEach {
            var offsetPointer = OffsetPointer(numberOfColums: numberOfColumns,
                                              yOffset: yOffset * rowHeight)
            let offsets = offsetPointer.getOffsets(count: numberOfItems + 3, freezeAt: $0)
            for offset in offsets {
                offsetBucket.append(offset)
            }
            yOffset = yOffset + 1
        }
        
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        var target = indexList[0] + pageNumber * numberOfItems
        inspectableRange = (pageNumber * numberOfItems) ..< (pageNumber * numberOfItems + pageSize)
        inspectableRange.forEach {
            let indexPath = IndexPath(item: $0, section: 0)
            
            if $0 % numberOfItems == 0  && inspectableRange.first != $0 {
                let index = pageNumber == 0 ? ($0 / numberOfItems) : ($0 / (pageNumber * numberOfItems))
                target = indexList[index] + numberOfItems * (pageNumber + index)
            }
            
            if $0 == target {
                frame = CGRect(x: columnWidth * CGFloat(offsetBucket[$0].0),
                               y: columnWidth * CGFloat(offsetBucket[$0].1),
                               width: columnWidth * 2,
                               height: columnWidth * 2)
            } else {
                frame = CGRect(x: columnWidth * CGFloat(offsetBucket[$0].0),
                               y: columnWidth * CGFloat(offsetBucket[$0].1),
                               width: columnWidth,
                               height: columnWidth)
            }
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            contentHeight = attributes.frame.maxY
            attributes.frame = insetFrame
            cache.append(attributes)
        }
        pageNumber = pageNumber + indexList.count
    }
   override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind,
                                                                                at: indexPath) else {
                                                                                    return nil
        }
        guard let collectionView = collectionView else {
            return layoutAttributes
        }
        guard let window = UIApplication.shared.keyWindow else {
            return .init()
        }
        let topPadding = window.safeAreaInsets.top
        let contentOffsetY = collectionView.contentOffset.y + 2 * topPadding
        var frameForSupplementaryView = layoutAttributes.frame
        let viewHeight = collectionView.frame.height - topPadding * 2
        let position = viewHeight - frameForSupplementaryView.height - topPadding
        frameForSupplementaryView.origin.y = contentOffsetY + position
        layoutAttributes.frame = frameForSupplementaryView
        
        return layoutAttributes
    }
}
