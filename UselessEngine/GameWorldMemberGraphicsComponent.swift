//
//  GameWorldMemberGraphicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/20/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

import SpriteKit

public protocol GameWorldMemberGraphicsComponent: GameWorldMemberObserver {

    var sprite: SKSpriteNode { get } // TODO: Consider replacing with SKTexture

    func update(with owner: GameWorldMember, dt: Float)

}
