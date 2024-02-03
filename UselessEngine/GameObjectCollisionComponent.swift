//
//  GameObjectCollisionComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/7/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public class GameObjectCollisionComponent {
    
    public var categoryBitmask: GameObjectCollisionCategories
    public var contactBitmask: GameObjectCollisionCategories
    public var collisionBitmask: GameObjectCollisionCategories
    
    public var contactAABB: AABB
    
    public init(categoryBitmask: GameObjectCollisionCategories, contactBitmask: GameObjectCollisionCategories, collisionBitmask: GameObjectCollisionCategories, contactAABB: AABB) {
        self.categoryBitmask = categoryBitmask
        self.contactBitmask = contactBitmask
        self.collisionBitmask = collisionBitmask
        self.contactAABB = contactAABB
    }

}
