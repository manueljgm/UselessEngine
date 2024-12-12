//
//  TestTileGraphicsComponent.swift
//  UselessEngineTests
//
//  Created by Manny Martins on 12/11/24.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

import SpriteKit
import UselessEngine

class TestTileGraphicsComponent: GameWorldMemberGraphicsComponent {
    
    var sprite: SKSpriteNode
    var transform: (Position) -> (point: CGPoint, zIndex: CGFloat)

    init() {
        sprite = SKSpriteNode()
        transform = { pos in return (.zero, 0.0) }
    }

    func update(with owner: GameTile, dt: Float) {
        // do nothing
    }
    
}
