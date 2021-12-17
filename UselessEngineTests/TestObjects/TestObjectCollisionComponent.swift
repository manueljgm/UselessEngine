//
//  TestObjectCollisionComponent.swift
//  UselessEngineTests
//
//  Created by Manny Martins on 12/13/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import UselessEngine

class TestObjectCollisionComponent: GameObjectCollisionComponent {
    
    var categoryBitmask: GameObjectCollisionCategories
    var contactBitmask: GameObjectCollisionCategories
    var collisionBitmask: GameObjectCollisionCategories
    var contactAABB: AABB
    
    init(categoryBitmask: GameObjectCollisionCategories,
         contactBitmask: GameObjectCollisionCategories,
         collisionBitmask: GameObjectCollisionCategories,
         contactAABB: AABB)
    {
        self.categoryBitmask = categoryBitmask
        self.contactBitmask = contactBitmask
        self.collisionBitmask = collisionBitmask
        self.contactAABB = contactAABB
    }
    
}
