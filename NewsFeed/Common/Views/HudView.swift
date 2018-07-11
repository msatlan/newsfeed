//
//  HudView.swift
//  NewsFeed
//
//  Created by MArko Satlan on 28/06/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit

class HudView: UIView {
// MARK: - Properties
    var text = ""

// MARK: - Methods
    // convenience constructor (class method)
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        
        hudView.show(animated: animated)
        return hudView
    }
    
    // draw
    override func draw(_ rect: CGRect) {
        let width: CGFloat = 96
        let height: CGFloat = 96
        
        // 1. - Rect
        let boxRect = CGRect(x: (bounds.size.width - width) / 2,
                             y: (bounds.size.height - height) / 2,
                             width: width,
                             height: height)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.9).setFill()
        roundedRect.fill()
        
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(x: center.x - image.size.width / 2,
                                     y: center.y - (image.size.height) / 2 - height / 8)
            image.draw(at: imagePoint)
           
        }
        
        // 2. - Label
        let label = UILabel()
        label.frame = CGRect(x: center.x - width / 2,
                             y: center.y,
                             width: width,
                             height: height / 2)
        label.text = text
        label.font = UIFont.georgia(ofSize: 16)
        label.textColor = UIColor.white
        label.textAlignment = .center
        addSubview(label)
    }
    
    // animate Hud
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                            self.alpha = 1
                            self.transform = CGAffineTransform.identity
            },
                           completion: nil)
        }
    }
}
