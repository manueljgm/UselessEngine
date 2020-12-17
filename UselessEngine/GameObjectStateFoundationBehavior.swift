//
//  GameObjectStateFoundationBehavior.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/26/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

open class GameObjectStateFoundationBehavior: Observer
{
    public var fallbackState: GameObjectState?
    
    public init() {
        
    }
    
    public final func enter(with gameObject: GameObject) {
        didEnter(with: gameObject)
    }
    
    open func didEnter(with gameObject: GameObject) {
        
    }

}
