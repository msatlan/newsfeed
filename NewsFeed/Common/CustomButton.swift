//
//  CustomButton.swift
//  NewsFeed
//
//  Created by MArko Satlan on 23/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = 151.0
        let height = 30.0
        self.frame.size = CGSize(width: width, height: height)
        
        self.layer.cornerRadius = 7
        self.clipsToBounds = true
        
        let titleColor = UIColor.white
        let highlightedTitleColor = UIColor.black
        
        self.setTitleColor(titleColor, for: .normal)
        self.setTitleColor(highlightedTitleColor, for: .highlighted)
        
        self.titleLabel?.font = UIFont.georgia(ofSize: 14)  
        
        self.setBackgroundImage(UIImage(named: "buttonNormal"), for: .normal)
        self.setBackgroundImage(UIImage(named: "buttonHighlighted"), for: .highlighted)
    }
}
