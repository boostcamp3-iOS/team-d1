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
        
        if diff1 > 10 || diff2 > 10 || diff3 > 10 {
            color = true
        }
        return color
        //return color ? "컬러" : "흑백"
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
        //return temperature ? "차가움" : "따뜻한"
    }
}

extension UIImage {
    //이미지의 평균 rgb값을 return해주는 확장 프로퍼티
    var averageColor: [String:Double]? {
        guard let imageData = self.jpegData(compressionQuality: 0.1) else { return nil }
        guard let inputImage = CIImage(data: imageData) else { return nil }
        let extentVector = CIVector(x: 0, y: 0, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        //CIAreaAverage - Returns a single-pixel image that contains the average color for the region of interest.
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil) //실제 filter를 이미지에 적용하는 부분 - render
        
        let doubleValue1 = Double(CGFloat(bitmap[0]))
        let doubleValue2 = Double(CGFloat(bitmap[1]))
        let doubleValue3 = Double(CGFloat(bitmap[2]))
        
        return ["r":doubleValue1, "g":doubleValue2, "b":doubleValue3]
    }
}

