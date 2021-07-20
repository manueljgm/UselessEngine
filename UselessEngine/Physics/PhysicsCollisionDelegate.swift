//
//  PhysicsCollisionDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/7/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public protocol PhysicsCollisionDelegate: AnyObject {
    
    var categoryBitmask: PhysicsCollisionCategories { get }
    var contactBitmask: PhysicsCollisionCategories { get }
    var collisionBitmask: PhysicsCollisionCategories { get }
    
    var contactAABB: AABB { get set }          
 
    func didUpdate(dt: Float)
    
    func handleContact(between gameObject: GameObject,
                       and otherObject: GameObject,
                       in world: GameWorld)
    
    func handleCollision(between gameObject: GameObject,
                         and otherObject: GameObject,
                         withCorrection correctionOffset: Vector,
                         in world: GameWorld)
    
}

extension PhysicsCollisionDelegate {

    public func didUpdate(dt: Float) {
        
    }
    
    public func handleContact(between gameObject: GameObject,
                              and otherGameObject: GameObject,
                              in world: GameWorld) {
        
    }
    
    public func handleCollision(between gameObject: GameObject,
                                and otherGameObject: GameObject,
                                withCorrection correctionOffset: Vector,
                                in world: GameWorld) {

    }
    
}
