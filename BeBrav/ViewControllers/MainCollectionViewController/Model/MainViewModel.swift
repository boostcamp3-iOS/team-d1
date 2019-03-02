//
//  MainViewModel.swift
//  BeBrav
//
//  Created by bumslap on 01/03/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

///checkIfValidPosition() 메서드가 적용된 이후 리턴되는 튜플을 구분하기 쉽게 적용한 type입니다.
typealias CalculatedInformation = (sortedArray: [ArtworkDecodeType], index: Int)


func calculateCellInfo(fetchedData: [ArtworkDecodeType],
                       batchSize: Int, columns: CGFloat)
    -> [CalculatedInformation]
{
    var mutableDataBucket = fetchedData
    var calculatedInfoBucket: [CalculatedInformation] = []
    let numberOfPages = fetchedData.count / batchSize
    for _ in 0..<numberOfPages {
        
        var currentBucket: [ArtworkDecodeType] = []
        for _ in 0..<batchSize {
            currentBucket.append(mutableDataBucket.removeLast())
        }
        let calculatedInfo: CalculatedInformation =
            checkIfValidPosition(data: currentBucket,
                                 numberOfColumns: Int(columns))
        calculatedInfoBucket.append(calculatedInfo)
        currentBucket.removeAll()
    }
    
    if !mutableDataBucket.isEmpty {
        let calculatedInfo: CalculatedInformation =
            checkIfValidPosition(data: mutableDataBucket,
                                 numberOfColumns: Int(columns))
        calculatedInfoBucket.append(calculatedInfo)
    }
    return calculatedInfoBucket
}
