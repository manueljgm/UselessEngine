//
//  ObserverNode.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/26/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import Foundation

public class ObserverNode {
    
    public let observer: Observer
    public var nextObserver: ObserverNode?
    
    public init(observer: Observer) {
        self.observer = observer
    }
    
}
