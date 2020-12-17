//
//  GameObjectStateGraphicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 7/30/15.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

import SpriteKit

public protocol GameObjectStateGraphicsComponent: GameObjectComponent, Observer {
    var animation: Animation { get }
    init(ownerState: GameObjectState, targetSprite: SKSpriteNode)
}

extension GameObjectStateGraphicsComponent {
    
    public func update(with gameObject: GameObject, dt: Float) {
        animation.update(dt)
    }
    
}
