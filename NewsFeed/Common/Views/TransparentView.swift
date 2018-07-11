//
//  TransarentView.swift
//  NewsFeed
//
//  Created by MArko Satlan on 21/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit

class TransparentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
}
