//
//  PaginatingCollectionViewControllerPresentAnimator.swift
//  BeBrav
//
//  Created by Seonghun Kim on 15/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class PaginatingViewControllerPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.3
    var originFrame = CGRect()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let finalFrame = toView.frame
        
        let scaleX = originFrame.width / finalFrame.width
        let scaleY = originFrame.height / finalFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        toView.transform = scaleTransform
        toView.center = CGPoint(x: originFrame.midX, y: originFrame.midY)
        toView.clipsToBounds = true
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(toView)
        
        UIView.animate(withDuration: duration, animations: {
            toView.transform = CGAffineTransform.identity
            toView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        },completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
