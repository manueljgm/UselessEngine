//
//  GameObjectStateWithGraphicsBehavior.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/20/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

open class GameObjectStateWithGraphicsBehavior<TGraphicsComponent: GameObjectStateGraphicsComponent>: Observer {
    
    public var fallbackState: GameObjectState?
    
    public private(set) var graphics: TGraphicsComponent?
    
    public init() {
        
    }
    
    deinit {
        print("StateWithGraphicsBehavior:deinit")
    }
    
    public final func enter(with gameObject: GameObject) {
        
        print("StateWithGraphicsBehavior:enter")

        if
            let ownerState = self as? GameObjectState,
            let targetSprite = gameObject.graphics?.sprite {
                self.graphics = TGraphicsComponent(ownerState: ownerState, targetSprite: targetSprite)
                self.graphics?.animation.renderFrame()
        }
        
        didEnter(with: gameObject)
    }
    
    open func didEnter(with gameObject: GameObject) {
        
    }
    
    public final func update(with gameObject: GameObject, dt: Float) {
        graphics?.update(with: gameObject, dt: dt)
        didUpdate(with: gameObject, dt: dt)
    }
    
    open func didUpdate(with gameObject: GameObject, dt: Float) {
        
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
    
    public final func receive(_ event: Event, from sender: AnyObject, payload: Any? = nil) {
        graphics?.receive(event, from: sender, payload: payload)
        didReceive(event, from: sender, payload: payload)
    }
    
    open func didReceive(_ event: Event, from sender: AnyObject, payload: Any? = nil) {
        
    }
}
