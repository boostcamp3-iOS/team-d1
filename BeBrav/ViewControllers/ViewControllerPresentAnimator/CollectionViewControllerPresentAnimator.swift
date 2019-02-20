//
//  PaginatingCollectionViewControllerPresentAnimator.swift
//  BeBrav
//
//  Created by Seonghun Kim on 15/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import UIKit

class CollectionViewControllerPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.3
    var viewFrame = CGRect()
    var originFrame = CGRect()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval
    {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let height = (viewFrame.height / viewFrame.width) * originFrame.height
        let frame = CGRect(x: originFrame.origin.x,
                           y: originFrame.origin.y,
                           width: originFrame.width,
                           height: height)
        
        let containerView = transitionContext.containerView
        let toViewFrame = toView.frame
        
        let scaleX = frame.width / toViewFrame.width
        let scaleY = frame.height / toViewFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        toView.transform = scaleTransform
        toView.center = CGPoint(x: originFrame.midX, y: originFrame.midY)
        toView.clipsToBounds = true
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(toView)
        
        UIView.animate(withDuration: duration, animations: {
            toView.transform = CGAffineTransform.identity
            toView.center = CGPoint(x: toViewFrame.midX, y: toViewFrame.midY)
        },completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
