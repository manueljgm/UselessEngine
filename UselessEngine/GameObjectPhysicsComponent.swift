//
//  GameObjectPhysicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/26/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public protocol GameObjectPhysicsComponent: GameObjectUpdateable, GameWorldMemberObserver {
    
    var mass: Float { get } // in kg
    var collision: GameObjectCollisionComponent { get }
    var gravityScale: Float { get set }
    var thrust: GameObjectThrustComponent? { get }

}

extension GameObjectPhysicsComponent {
    
    public func update(with gameObject: GameObject, dt: Float) {
        collision.contactAABB.position = gameObject.position
        thrust?.update(with: gameObject, dt: dt)
    }

}
