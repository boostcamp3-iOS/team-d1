//
//  imageSort.swift
//  BeBrav
//
//  Created by 공지원 on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

struct ImageSort                                                                                                                                                                                                                                                       {
    var orientation = false //true면 가로, false면 세로
    var color = false //true면 컬러, false면 흑백
    var temperature = false //true면 쿨톤, false면 웜톤
    
    var image: UIImage?
    
    init(input image: UIImage?) {
        self.image = image
    }
    
    //알고리즘1 - 가로/세로 분류
    mutating func orientationSort() -> Bool? {
        guard let image = image else { return nil}
        
        //가로,세로 길이가 같으면 가로이미지로 간주
        orientation = (image.size.width >= image.size.height)
        
        return orientation
    }
    
    //알고리즘2 - 컬러/흑백 분류
    mutating func colorSort() -> Bool? {
        guard let image = image else { return nil }
        guard let averageColor = image.averageColor else { return nil }
        guard let r = averageColor["r"], let g = averageColor["g"], let b = averageColor["b"] else { return nil }
        
        let diff1 = abs(r-g)
        let diff2 = abs(r-b)
        let diff3 = abs(g-b)
        
        if diff1 > 3 || diff2 > 3 || diff3 > 3 {
            color = true
        }
        return color
    }
    
    //알고리즘3 - 차가운/따뜻한 이미지 분류
    //FIXME: - 더 개선해볼것
    mutating func temperatureSort() -> Bool? {
        guard let image = image else { return nil }
        guard let averageColor = image.averageColor else { return nil }
        guard let r = averageColor["r"], let g = averageColor["g"], let b = averageColor["b"] else { return nil }
        
        //FIXME: - 기준을 좀 더 구체화 해보기
        if r > g && r > b {
            if b > g && (b-g > 60) {
                temperature = true
            }
        } else if g > r && g > b {
            if b > r && (b-r > 60) {
                temperature = true
            }
        } else if b > r && b > g {
            if g > r {
                temperature = true
            }
        }
        return temperature
    }
}
