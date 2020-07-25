//
//  GameObjectPhysicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/26/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

import Foundation

public protocol GameObjectPhysicsComponent: GameObjectComponent {
    
    var mass: Float { get } // in kg
    var thrust: Vector { get set }
    var boost: Boost? { get set }
    
    /// Indicates whether the game object is touching the tile underfoot.
    var touchingGround: Bool { get }

    /// Determines whether the game object should be handled as airborne despite being in contact with the ground.
    var simulateAir: Bool { get set }
    
    /// Reference to collision delegate that manages contact and collision behavior for this object.
    var collisionDelegate: PhysicsCollisionDelegate? { get set }
    
    func positionDidChange(from previousPosition: Position, for owner: GameObject)
    
}
