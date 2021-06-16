//
//  GameObjectStateGraphicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 7/30/15.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

import SpriteKit

public protocol GameObjectStateGraphicsComponent: GameWorldMemberObserver {

    var animation: Animation { get }

    init(ownerState: GameObjectState, targetSprite: SKSpriteNode)
    func update(with owner: GameObject, in world: GameWorld, dt: Float)

}

extension GameObjectStateGraphicsComponent {
    
    public func update(with gameObject: GameObject, in world: GameWorld, dt: Float) {
        animation.update(dt)
    }
    
}
