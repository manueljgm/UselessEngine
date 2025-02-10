//
//  TestObjectPhysicsComponent.swift
//  UselessEngineTests
//
//  Created by Manny Martins on 12/13/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import UselessEngine

class TestObjectPhysicsComponent: GameObjectPhysicsComponent {
    
    var mass: Float
    var collision: GameObjectCollisionComponent
    var gravityScale: Float
    var thrust: GameObjectThrustComponent?
    
    init(mass: Float,
         collision: GameObjectCollisionComponent,
         gravityScale: Float,
         thrust: GameObjectThrustComponent?,
         distanceTraveled: Float)
    {
        self.mass = mass
        self.collision = collision
        self.gravityScale = gravityScale
        self.thrust = thrust
    }
    
}
