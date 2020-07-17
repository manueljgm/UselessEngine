//
//  PhysicsCollisionDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/7/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import Foundation

public protocol PhysicsCollisionDelegate: class {

    var categoryBitmask: PhysicsCollisionCategories { get }
    var contactBitmask: PhysicsCollisionCategories { get }
    var collisionBitmask: PhysicsCollisionCategories { get }
    
    var contactAABB: AABB { get }
 
    func testContact(against otherGameObject: GameObject) -> Bool
    func handleContact(of gameObject: GameObject, against otherGameObject: GameObject)
    
    func testCollision(against otherGameObject: GameObject) -> Hit?
    func handleCollisionEvent(on gameObject: GameObject, withCorrectionOffsetOf correctionOffset: Vector)
    
}

extension PhysicsCollisionDelegate {
    
    public func testContact(against otherGameObject: GameObject) -> Bool {
        guard let otherCollisionDelegate = otherGameObject.physics?.collisionDelegate else {
            return false
        }

        let isContactable =
            (categoryBitmask.rawValue & otherCollisionDelegate.contactBitmask.rawValue > 0) ||
            (contactBitmask.rawValue & otherCollisionDelegate.categoryBitmask.rawValue > 0)
        return isContactable ? (contactAABB.intersects(with: otherCollisionDelegate.contactAABB) != nil) : false
    }
    
    public func handleContact(of gameObject: GameObject, against otherGameObject: GameObject) {
    }
    
    public func testCollision(against otherGameObject: GameObject) -> Hit? {
        guard let otherCollisionDelegate = otherGameObject.physics?.collisionDelegate else {
            return nil
        }
        
        let isCollideable =
            (categoryBitmask.rawValue & otherCollisionDelegate.collisionBitmask.rawValue > 0) ||
            (collisionBitmask.rawValue & otherCollisionDelegate.categoryBitmask.rawValue > 0)
        return isCollideable ? contactAABB.intersects(with: otherCollisionDelegate.contactAABB) : nil
    }
    
    public func handleCollisionEvent(on gameObject: GameObject, withCorrectionOffsetOf correctionOffset: Vector) {
    }
    
}
