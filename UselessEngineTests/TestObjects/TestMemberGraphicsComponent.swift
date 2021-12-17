//
//  TestMemberGraphicsComponent.swift
//  UselessEngineTests
//
//  Created by Manny Martins on 12/13/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import SpriteKit
import UselessEngine

class TestMemberGraphicsComponent: GameWorldMemberGraphicsComponent {
    
    var sprite: SKSpriteNode
    
    init() {
        sprite = SKSpriteNode()
    }
    
    func update(with owner: GameWorldMember, dt: Float) {
        // do nothing
    }
    
}
