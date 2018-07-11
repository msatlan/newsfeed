//
//  Functions.swift
//  NewsFeed
//
//  Created by MArko Satlan on 28/06/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}
