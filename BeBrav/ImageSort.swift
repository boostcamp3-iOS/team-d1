//
//  imageSort.swift
//  BeBrav
//
//  Created by 공지원 on 06/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit
import CoreImage
import CoreGraphics

struct ImageSort                                                                                                                                                                                                                                                       {
    var orientation = false //true면 가로, false면 세로
    var color = false //true면 컬러, false면 흑백
    var temperature = false //true면 쿨톤, false면 웜톤
    
    var image: UIImage?
    
    init(input image: UIImage?) {
        self.image = image
    }
    
    mutating func sort() -> String {
        guard let image = image else { return "invalid image" }
        
        guard let averageColor = image.averageColor else {
            return "invalid average color"
        }
        
        //알고리즘1
        //가로,세로 길이가 같으면 가로이미지로 간주
        if image.size.width >= image.size.height {
            orientation = true
        } else {
            orientation = false
        }
        
        //알고리즘2
        let diff1 = abs(averageColor[0] - averageColor[1])
        let diff2 = abs(averageColor[0] - averageColor[2])
        let diff3 = abs(averageColor[1] - averageColor[2])
        
        if diff1>10 || diff2>10 || diff3>10 {
            color = true
        }
        
        //알고리즘3
        let r = averageColor[0]
        let g = averageColor[1]
        let b = averageColor[2]
        
        //FIXME: - 기준을 좀 더 구체화 해보기
        if r>g && r>b {
            if b>g && (b-g>60) {
                temperature = true
            }
        } else if g>r && g>b {
            if b>r && (b-r>60) {
                temperature = true
            }
        } else if b>r && b>g {
            if g>r {
                temperature = true
            }
        }
        
        return "\(orientation), \(color), \(temperature)"
    }
}

extension UIImage {
    //이미지의 평균 rgb값을 return해주는 확장 프로퍼티
    var averageColor: [Double]? {
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
        
        return [doubleValue1, doubleValue2, doubleValue3]
    }
}
