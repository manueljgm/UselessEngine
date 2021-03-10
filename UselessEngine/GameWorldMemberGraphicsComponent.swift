//
//  GameWorldMemberGraphicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/20/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

import SpriteKit

public protocol GameWorldMemberGraphicsComponent: class, GameWorldMemberObserver {

    var sprite: SKSpriteNode { get }

    func update(with owner: GameWorldMember, dt: Float)

}
