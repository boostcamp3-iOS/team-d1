//
//  UIImage+\.swift
//  BeBrav
//
//  Created by bumslap on 12/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

extension UIImage {
    func scale(with scale: CGFloat) -> UIImage {
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        format.scale = self.scale
        
        let render = UIGraphicsImageRenderer(size:size, format: format)
        let image = render.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return image
    }
}

extension UIImage {
    //이미지의 평균 rgb값을 return해주는 확장 프로퍼티
    var averageColor: [String:Double]? {
        //let resizedImage = self.scale(with: 0.1)
        guard let inputImage = CIImage(image: self) else { return nil }
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
