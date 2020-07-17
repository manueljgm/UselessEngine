//
//  GameObjectStateFoundationBehavior.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/26/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

open class GameObjectStateFoundationBehavior: Observer {
    
    public var fallbackState: GameObjectState?
    
    public init() {
        
    }
    
    public final func enter(with gameObject: GameObject) {
        didEnter(with: gameObject)
    }
    
    open func didEnter(with gameObject: GameObject) {
        
    }
    
    public func push(gameObject: GameObject, to newState: GameObjectState) {
        guard let state = self as? GameObjectState else {
            return
        }
        newState.fallbackState = state
        gameObject.enter(state: newState)
    }
    
    open func willExit(for gameObject: GameObject) {

    }
    
    public final func exit(for gameObject: GameObject) {
        willExit(for: gameObject)
        gameObject.state = fallbackState
        gameObject.state?.reset(with: gameObject)
    }
    
}
