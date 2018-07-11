//
//  ClosingAnimationController.swift
//  NewsFeed
//
//  Created by MArko Satlan on 21/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit

class ClosingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
            let containerView = transitionContext.containerView
            fromView.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                    delay: 0,
                                    options: .calculationModeCubic,
                                    animations: {
                                        UIView.addKeyframe(withRelativeStartTime: 0,
                                                           relativeDuration: 0.334,
                                                           animations: {
                                                            fromView.transform = CGAffineTransform(scaleX: 0.66, y: 0.66)
                                                            fromView.center.y = (containerView.center.y - fromView.center.y) * 0.66
                                        })
                                        UIView.addKeyframe(withRelativeStartTime: 0.334,
                                                           relativeDuration: 0.333,
                                                           animations: {
                                                            fromView.transform = CGAffineTransform(scaleX: 0.33, y: 0.33)
                                                            fromView.center.y = (containerView.center.y - fromView.center.y) * 0.33
                                        })
                                        UIView.addKeyframe(withRelativeStartTime: 0.666,
                                                           relativeDuration: 0.333,
                                                           animations: {
                                                            fromView.transform = CGAffineTransform(scaleX: 0, y: 0)
                                                            fromView.center.y = 81
                                        })
            },
                                    completion: {
                                        finished in
                                        transitionContext.completeTransition(finished)
            })
        }
    }
}

