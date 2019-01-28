//
//  AutoResizingCollecionViewModel.swift
//  BeBrav
//
//  Created by bumslap on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

func findMostViewedArtwork(in data: [Artwork]) -> [Int] {
    var index: [Int] = []
    let middle = data.count / 2
    let firstPage = data[0..<middle]
    let secondePage = data[middle...]
    guard let firstIndex = firstPage.firstIndex(of: firstPage.max() ?? Artwork(views: 0, image: nil)) else { return [0]}
    guard let secondIndex = secondePage.firstIndex(of: secondePage.max() ?? Artwork(views: 0, image: nil)) else { return [0]}
    index = [firstIndex, secondIndex]
    return index
}

func checkIfValidPosition(data: [Artwork], numberOfColumns: Int) -> [Artwork] {
    var mutableDataArray = data
    var index = findMostViewedArtwork(in: data)
    let numberOfData = data.count
    if index[0] + 1 == index[1] {
        mutableDataArray.swapAt(index[0], index[0]-1)
        index[0] = index[0] - 1
    }
    index.forEach {
        if (($0 + 1) % numberOfColumns) == 0 {
            if $0 == numberOfData {
                mutableDataArray[$0].isMostViewedArtwork = true
                mutableDataArray.swapAt($0, $0-1)
                // data request and push it
            } else {
                mutableDataArray[$0].isMostViewedArtwork = true
                mutableDataArray.swapAt($0, $0+1)
            }
        }
    }
    return mutableDataArray
}

func calculateNumberOfArtworksPerPage(numberOfColums: CGFloat, viewWidth: CGFloat, viewHeight: CGFloat, spacing: CGFloat, insets: CGFloat) -> Int {
    let window = UIApplication.shared.keyWindow
    let topPadding = window?.safeAreaInsets.top
    let insetsNumber = numberOfColums + 1
    let width = (viewWidth - insetsNumber * (spacing -  insets)) / numberOfColums
    var height = (viewHeight - CGFloat(topPadding ?? 0)) / width
    height.round(FloatingPointRoundingRule.toNearestOrEven)
    let numberOfItems = Int(height * numberOfColums - 3)
    return numberOfItems
}

func calculatePositionOfMostViewedArtwork() {
    
}
func generateOffSets(numberOfColumns: Int, numberOfItems: Int, indexOfMostViewedItem: Int) -> [(Int,Int)]{
    assert((indexOfMostViewedItem+1) % numberOfColumns != 0, "not implemented yet")
    // indexOfMostViewedItem row에서 처음일 경우만 구현됨
    var offsetBucket: [(Int,Int)] = []
    var rowIndex = 0
    var isMostViewedItemFound = false
    var isOnce = true
    if numberOfItems % numberOfColumns == 0 {
        let loopCount = numberOfItems / numberOfColumns
        var lastValue = -1
        for row in 0..<loopCount {
            for column in 0..<numberOfColumns {
                var coordinate = (0,0)
                if indexOfMostViewedItem / numberOfColumns == row {
                    if isOnce {
                        coordinate = (xOffset: 0, yOffset: row)
                        isOnce = false
                        isMostViewedItemFound = true
                    } else {
                        coordinate = (xOffset: numberOfColumns - 1, yOffset: column + lastValue)
                    }
                    //lastValue = lastValue - 1
                } else {
                    coordinate = (xOffset: column, yOffset: row+1)
                }
                offsetBucket.append(coordinate)
            }
            if isMostViewedItemFound {
                rowIndex = rowIndex + 1
                isMostViewedItemFound = false
            }
            rowIndex = rowIndex + 1
        }
    } else {
        return [(0,0)]
    }
    return offsetBucket
}
