//
//  GameObjectCollisionComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/7/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public class GameObjectCollisionComponent {
    
    public private(set) var categoryBitmask: GameObjectCollisionCategories
    
    public var contactBitmask: GameObjectCollisionCategories {
        return isContactEnabled ? _contactBitmask : .none
    }
    
    public var collisionBitmask: GameObjectCollisionCategories {
        return isCollisionEnabled ? _collisionBitmask : .none
    }
    
    public var contactAABB: AABB
    
    private var _contactBitmask: GameObjectCollisionCategories
    private var _collisionBitmask: GameObjectCollisionCategories
    
    private var isContactEnabled = true
    private var isCollisionEnabled = true
    
    public init(categoryBitmask: GameObjectCollisionCategories, contactBitmask: GameObjectCollisionCategories, collisionBitmask: GameObjectCollisionCategories, contactAABB: AABB) {
        self.categoryBitmask = categoryBitmask
        _contactBitmask = contactBitmask
        _collisionBitmask = collisionBitmask
        self.contactAABB = contactAABB
    }

    public func toggleContact(enabled enable: Bool) {
        isContactEnabled = enable
    }

    public func toggleCollision(enabled enable: Bool) {
        isCollisionEnabled = enable
    }
    
}
