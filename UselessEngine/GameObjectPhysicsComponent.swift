//
//  GameObjectPhysicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/26/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public protocol GameObjectPhysicsComponent: GameObjectComponent
{
    var mass: Float { get } // in kg
    var thrust: Vector { get set }
    var boost: Boost? { get set }
    
    /// Indicates whether the game object is touching the tile underfoot.
    var isTouchingGround: Bool { get set }

    /// Determines whether the game object should be handled as airborne despite being in contact with the ground.
    var forceAirborne: Bool { get set }
    
    /// Reference to collision delegate that manages contact and collision behavior for this object.
    var collisionDelegate: PhysicsCollisionDelegate? { get set }
    
    func receive(event: EngineEvent, from owner: GameObject)
}
