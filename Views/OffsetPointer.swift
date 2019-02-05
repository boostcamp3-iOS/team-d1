//
//  OffsetPointer.swift
//  BeBrav
//
//  Created by bumslap on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

struct OffsetPointer {
    
    var referenceColumn: [Int]
    var xOffsetBucket: [[Int]] = []
    var yOffsetBucket: [[Int]] = []
    var isNextRowFreezed = false
    var xOffsetPointer = 0
    var yOffsetPointer = 0
    let position: Position
    let block = -1
    
    init(numberOfColums: Int, position: Position) {
        
        self.position = position
        self.referenceColumn = Array(repeating: 0, count: numberOfColums)
        for index in 0..<numberOfColums {
            self.referenceColumn[index] = index
        }
    }
    
    mutating func getOffsets(count: Int, freezeAt number: Int) -> [(CGFloat, CGFloat)]{
        calculateOffsets(count: count, freezeAt: number)
        var zippedBucket: [(CGFloat, CGFloat)] = []
        for index in 0..<xOffsetBucket.count - 1 {
            Array(zip(xOffsetBucket[index],yOffsetBucket[index]))
                .filter{
                    $0.0 != block
                }
                .forEach {
                    let transformedTuple = (CGFloat($0.0), CGFloat($0.1))
                    zippedBucket.append(transformedTuple)
            }
        }
        return zippedBucket
    }
    
    private mutating func restore() {
        for index in 0..<referenceColumn.count {
            self.referenceColumn[index] = index
        }
    }
    
    private mutating func freeze() {
        referenceColumn[xOffsetPointer] = -1
        isNextRowFreezed = true
    }
    
    private mutating func calculateOffsets(count: Int, freezeAt: Int) {
        for number in 0..<count {
            
            if (referenceColumn.count - 1) == xOffsetPointer {
                xOffsetBucket.append(referenceColumn)
                yOffsetBucket.append(Array(repeating: yOffsetPointer, count: 3))
                yOffsetPointer = yOffsetPointer + 1
                
            }
            
            if (referenceColumn.count - 1) == xOffsetPointer && isNextRowFreezed {
                
                switch position {
                case .left:
                    referenceColumn[0] = block
                    xOffsetBucket.append(referenceColumn)
                    isNextRowFreezed = false
                    restore()
                case .right:
                    referenceColumn[xOffsetPointer] = block
                    referenceColumn[xOffsetPointer - 1] = block
                    xOffsetBucket.append(referenceColumn)
                    isNextRowFreezed = false
                    restore()
                }
            }
            
            xOffsetPointer = xOffsetPointer < (referenceColumn.count - 1) ?
                (xOffsetPointer + 1) : 0
            
            if number == freezeAt {
                freeze()
            }
        }
    }
}
