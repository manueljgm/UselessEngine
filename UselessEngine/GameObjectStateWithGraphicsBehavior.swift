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
        #if DEBUG_VERBOSE
        print("GameObjectStateWithGraphicsBehavior:init")
        #endif
    }
    
    deinit {
        #if DEBUG_VERBOSE
        print("GameObjectStateWithGraphicsBehavior:deinit")
        #endif
    }
    
    public final func enter(with gameObject: GameObject)
    {
        #if DEBUG_VERBOSE
        print("GameObjectStateWithGraphicsBehavior:enter")
        #endif

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

    public final func receive(_ event: EngineEvent, from sender: AnyObject, payload: Any? = nil) {
        graphics?.receive(event, from: sender, payload: payload)
    }
    
}
