//
//  GameWorldMemberGraphicsComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/20/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

import SpriteKit

public protocol GameWorldMemberGraphicsComponent: GameWorldMemberObserver {

    var sprite: SKSpriteNode { get }
    var transform: (_ position: Position) -> (point: CGPoint, zIndex: CGFloat) { get set }

    func update(with owner: GameWorldMember, dt: Float)

}

public extension GameWorldMemberGraphicsComponent {
    
    func update(with owner: GameWorldMember, dt: Float) {
        let viewspacePosition = transform(owner.position)
        sprite.position = viewspacePosition.point
        sprite.zPosition = viewspacePosition.zIndex
    }
    
}
