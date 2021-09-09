//
//  AnimationDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/27/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import Foundation

public protocol AnimationDelegate: AnyObject {
    
    func didFinish(animation: Animation)
    
}

extension AnimationDelegate {
    
    func didFinish(animation: Animation) {
        
    }
    
}
