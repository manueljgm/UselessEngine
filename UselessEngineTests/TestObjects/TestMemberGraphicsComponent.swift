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
    var transform: (Position) -> (point: CGPoint, zIndex: CGFloat)

    init() {
        sprite = SKSpriteNode()
        transform = { pos in return (.zero, 0.0) }
    }
    
    func update(with owner: GameWorldMember, dt: Float) {
        // do nothing
    }
    
}
