//
//  GameObjectPhysicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/26/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public protocol GameObjectPhysicsComponent: GameWorldMemberObserver {
    
    var mass: Float { get } // in kg
    
    var gravityScale: Float { get set }
    
    /// Reference to thrust delegate that manages the thrust behavior for this object.
    var thrustDelegate: PhysicsThrustDelegate? { get }
    
    /// Reference to collision delegate that manages contact and collision behavior for this object.
    var collisionDelegate: PhysicsCollisionDelegate { get }
    
    var distanceTraveled: Float { get } // in m
    
    func update(with gameObject: GameObject, in world: GameWorld, dt: Float)
    
}

extension GameObjectPhysicsComponent {
    
    func update(with gameObject: GameObject, in world: GameWorld, dt: Float) {
        thrustDelegate?.update(with: gameObject, in: world, dt: dt)
    }

}
