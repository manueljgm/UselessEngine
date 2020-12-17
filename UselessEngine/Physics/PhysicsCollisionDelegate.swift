//
//  PhysicsCollisionDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/7/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public protocol PhysicsCollisionDelegate: class
{
    var categoryBitmask: PhysicsCollisionCategories { get }
    var contactBitmask: PhysicsCollisionCategories { get }
    var collisionBitmask: PhysicsCollisionCategories { get }
    
    var contactAABB: AABB { get set }
    var contactWithConsequences: Bool { get set }
 
    func testContact(against otherGameObject: GameObject) -> Bool
    func handleContact(between gameObject: GameObject, and otherGameObject: GameObject)
    
    func testCollision(against otherGameObject: GameObject) -> Hit?
    func handleCollision(between gameObject: GameObject, and otherGameObject: GameObject, withCorrection correctionOffset: Vector)
}

extension PhysicsCollisionDelegate
{
    public func testContact(against otherGameObject: GameObject) -> Bool
    {
        guard let otherCollisionDelegate = otherGameObject.physics?.collisionDelegate else {
            return false
        }

        let isContactable =
            (categoryBitmask.rawValue & otherCollisionDelegate.contactBitmask.rawValue > 0) ||
            (contactBitmask.rawValue & otherCollisionDelegate.categoryBitmask.rawValue > 0)
        return isContactable ? (contactAABB.intersect(otherCollisionDelegate.contactAABB, withTolerance: 0.1) != nil) : false
    }
    
    public func handleContact(between gameObject: GameObject, and otherGameObject: GameObject) {
        
    }
    
    public func testCollision(against otherGameObject: GameObject) -> Hit?
    {
        guard let otherCollisionDelegate = otherGameObject.physics?.collisionDelegate else {
            return nil
        }
        
        let isCollideable =
            (categoryBitmask.rawValue & otherCollisionDelegate.collisionBitmask.rawValue > 0) ||
            (collisionBitmask.rawValue & otherCollisionDelegate.categoryBitmask.rawValue > 0)
        return isCollideable ? contactAABB.intersect(otherCollisionDelegate.contactAABB, withTolerance: 0.1) : nil
    }
    
    public func handleCollision(between gameObject: GameObject, and otherGameObject: GameObject, withCorrection correctionOffset: Vector) {
        
    }

}
