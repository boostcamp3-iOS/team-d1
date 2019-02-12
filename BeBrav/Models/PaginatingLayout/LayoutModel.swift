//
//  LayoutModel.swift
//  BeBrav
//
//  Created by bumslap on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit


/// ArtworkDecodeType배열을 받아서 각 인스탠스의 views 프로퍼티를 배열안에 담아서 해당 배열에서 가장
/// 큰 값의 인덱스를 받환합니다. Comparable을 timestamp비교에 사용하고 있기때문에 추가적인 배열이 필요합니다.
///
/// - Parameters:
///   - data: ArtworkDecodeType 타입의 배열을 인자로 받습니다.
/// - Returns: 배열을 검사한 이후에 views가 가장 큰 원소의 index를 리턴합니다.
func findMostViewedArtwork(in data: [ArtworkDecodeType]) -> Int {
    var viewsTempArray: [Int] = []
    for view in data {
        viewsTempArray.append(view.views)
    }
    guard let index = viewsTempArray.firstIndex(of: viewsTempArray.max() ?? 0) else { return 0 }
    return index
}


/// 레이아웃에서 2x2셀은 가장 오른쪽 컬럼에 나오게 되면 위치가 애매해지기 때문에 이 메서드를 한번 거쳐서
/// 첫번째 또는 두번째(3개의 컬럼일 때) 컬럼에만 해당 셀이 나올 수 있도록 데이터를 바꿔줍니다.
///
/// - Parameters:
///   - data: ArtworkDecodeType 타입의 배열을 인자로 받습니다.
///   - numberOfColumns: 컬럼의 갯수를 인자로 받습니다.
/// - Returns: 배열을 검사하여 적절한 데이터로 바꿔준 이후 인덱스와 함께 튜플로 리턴합니다.
func checkIfValidPosition(data: [ArtworkDecodeType],
                          numberOfColumns: Int) -> ([ArtworkDecodeType], Int) {
    var mutableDataArray = data
    var index = findMostViewedArtwork(in: data)
   
        if ((index + 1) % numberOfColumns) == 0 {
                mutableDataArray.swapAt(index, index - 1)
                index = index - 1
        }
    
    return (sortedArray: mutableDataArray, index: index)
}


/// 한 페이지당 데이터가 몇개 필요한지 계산하기 위해서 calculateNumberOfArtworksPerPage() 메서드를
/// 사용합니다. 1x1 셀로 화면 1개를 가득채운다고 가정하고 계산한 이후에 3개를 빼주게 되는데 이는 2x2 셀이
/// 다른 셀의 4배의 공간을 차지하기 때문입니다. 리턴된 값은 batchSize를 계산하는데에 사용됩니다.
///
/// - Parameters:
///   - numberOfColumns: 컬럼의 갯수를 인자로 받습니다.
///   - viewWidth: 현재 기기의 width를 인자로 받습니다.
///   - viewHeight: 현재 기기의 height를 인자로 받습니다.
///   - spacing: CollectionView에 적용될 spacing입니다.
///   - insets: CollectionView에 적용될 inset입니다.
/// - Returns: 연산한 데이터의 갯수를 리턴합니다.
func calculateNumberOfArtworksPerPage(numberOfColumns: CGFloat,
                                      viewWidth: CGFloat,
                                      viewHeight: CGFloat,
                                      spacing: CGFloat,
                                      insets: CGFloat) -> Int {
    let window = UIApplication.shared.keyWindow
    let topPadding = window?.safeAreaInsets.top
    let insetsNumber = numberOfColumns + 1
    let width = (viewWidth - insetsNumber * (spacing -  insets)) / numberOfColumns
    
    var height = (viewHeight - CGFloat(topPadding ?? 0)) / width
    height.round(FloatingPointRoundingRule.toNearestOrEven)
    
    let numberOfItems = Int(height * numberOfColumns - 3)
    return numberOfItems
}

///레이아웃에서 왼쪽에 2x2 셀이 올지 오른쪽에 올지 표현하기 위해 만든 enum타입 입니다.
enum Position {
    case left
    case right
}

