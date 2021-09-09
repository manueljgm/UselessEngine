//
//  GameObjectPhysicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/26/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public protocol GameObjectPhysicsComponent: GameWorldUpdateable, GameWorldMemberObserver {
    
    var mass: Float { get } // in kg
    var collision: GameObjectCollisionComponent { get }
    var gravityScale: Float { get set }
    var thrust: GameObjectThrustComponent? { get }
    var distanceTraveled: Float { get } // in m

}

extension GameObjectPhysicsComponent {
    
    public func update(with gameObject: GameObject, in world: GameWorld, dt: Float) {
        thrust?.update(with: gameObject, in: world, dt: dt)
    }

}
