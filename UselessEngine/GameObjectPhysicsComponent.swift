//
//  GameObjectPhysicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/26/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public protocol GameObjectPhysicsComponent: class, GameObjectObserver {
    
    var id: UUID { get }
    var mass: Float { get } // in kg
    var thrust: Vector { get set }
    var boost: Boost? { get set }
    var addDrag: Bool { get set }
    
    /// Reference to collision delegate that manages contact and collision behavior for this object.
    var collisionDelegate: PhysicsCollisionDelegate? { get set }
    
    func update(with owner: GameObject, in world: GameWorld, dt: Float)
    
}
