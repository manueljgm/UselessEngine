//
//  PhysicsCollisionDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/7/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public protocol PhysicsCollisionDelegate
{
    var categoryBitmask: PhysicsCollisionCategories { get }
    var contactBitmask: PhysicsCollisionCategories { get }
    var collisionBitmask: PhysicsCollisionCategories { get }
    
    var contactAABB: AABB { get set }
    var contactWithConsequences: Bool { get set }
 
    func handleContact(between gameObject: GameObject, and otherGameObject: GameObject)
    func handleCollision(between gameObject: GameObject,
                         and otherGameObject: GameObject,
                         withCorrection correctionOffset: Vector,
                         in world: GameWorld)
}

extension PhysicsCollisionDelegate
{
    public func handleContact(between gameObject: GameObject, and otherGameObject: GameObject) {
        
    }
    
    public func handleCollision(between gameObject: GameObject,
                                and otherGameObject: GameObject,
                                withCorrection correctionOffset: Vector,
                                in world: GameWorld) {

    }
}
