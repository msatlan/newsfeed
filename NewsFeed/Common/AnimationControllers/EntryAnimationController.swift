//
//  EntryAnimationController.swift
//  NewsFeed
//
//  Created by MArko Satlan on 21/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit

class EntryAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            
            let containerView = transitionContext.containerView
            toView.frame = transitionContext.finalFrame(for: toViewController)
            toView.center.y = 81
            containerView.addSubview(toView)
            toView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            
            UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                    delay: 0,
                                    options: .calculationModeCubic,
                                    animations: {
                                        UIView.addKeyframe(withRelativeStartTime: 0,
                                                           relativeDuration: 0.334,
                                                           animations: {
                                                            toView.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
                                                            toView.center.y = (containerView.center.y - toView.center.y) * 0.33
                                        })
                                        UIView.addKeyframe(withRelativeStartTime: 0.334,
                                                           relativeDuration: 0.333,
                                                           animations: {
                                                            toView.transform = CGAffineTransform(scaleX: 0.66, y: 0.66)
                                                            toView.center.y = (containerView.center.y - toView.center.y) * 0.66
                                        })
                                        UIView.addKeyframe(withRelativeStartTime: 0.666,
                                                           relativeDuration: 0.333,
                                                           animations: {
                                                            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                                            toView.center.y = containerView.center.y
                                        })
            },
                                    completion: {
                                        finished in
                                        transitionContext.completeTransition(finished)
            })
        }
    }
}
