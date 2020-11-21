//
//  GameEntityGraphicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/20/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

import SpriteKit

public protocol GameEntityGraphicsComponent: GameEntityComponent {
    var sprite: SKSpriteNode { get }
    func receive(event: EngineEvent, from owner: GameEntity)
}
