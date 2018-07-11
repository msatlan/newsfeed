//
//  PresentationController.swift
//  NewsFeed
//
//  Created by MArko Satlan on 19/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit
import Foundation

class PresentationController: UIPresentationController {
    
    lazy var transparentView = TransparentView(frame: CGRect.zero)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        transparentView.frame = containerView!.bounds
        containerView!.insertSubview(transparentView, at: 0)
        
        transparentView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: {
                _ in
                self.transparentView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: {
                _ in
                self.transparentView.alpha = 0
            }, completion: nil)
        }
    }
}
