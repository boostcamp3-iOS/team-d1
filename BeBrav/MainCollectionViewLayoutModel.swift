//
//  MainCollectionViewLayoutModel.swift
//  BeBrav
//
//  Created by bumslap on 25/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

func findMostViewedArtwork(in data: [Int]) -> [Int] {
    var index: [Int] = []
    let middle = data.count / 2
    let firstPage = data[0..<middle]
    let secondePage = data[middle...]
    let firstIndex = firstPage.firstIndex(of: firstPage.max() ?? 0)
    let secondIndex = secondePage.firstIndex(of: secondePage.max() ?? 0)
    index = [firstIndex!, secondIndex!]
    return index
}

func checkIfValidPosition(data: [Int], numberOfColumns: Int) -> [Int] {
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
                mutableDataArray.swapAt($0, $0-1)
                // data request and push it
            } else {
                mutableDataArray.swapAt($0, $0+1)
            }
        }
    }
    return mutableDataArray
}
