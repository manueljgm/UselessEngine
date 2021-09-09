//
//  GameObjectCollisionComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/7/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public protocol GameObjectCollisionComponent: AnyObject {
    
    var categoryBitmask: GameObjectCollisionCategories { get }
    var contactBitmask: GameObjectCollisionCategories { get set }
    var collisionBitmask: GameObjectCollisionCategories { get set }
    
    var contactAABB: AABB { get set }
    
}
