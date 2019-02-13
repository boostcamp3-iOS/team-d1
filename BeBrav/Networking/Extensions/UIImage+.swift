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
        let formet = UIGraphicsImageRendererFormat.default()
        formet.opaque = true
        formet.scale = self.scale
        
        let render = UIGraphicsImageRenderer(size:size, format: formet)
        let image = render.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return image
    }
}
