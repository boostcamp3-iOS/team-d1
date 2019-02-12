//
//  UIImage+\.swift
//  BeBrav
//
//  Created by bumslap on 12/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

extension UIImage {
    func scale(with scale: CGFloat) -> UIImage? {
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(size, true, self.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
