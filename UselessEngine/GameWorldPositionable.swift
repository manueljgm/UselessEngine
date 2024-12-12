//
//  GameWorldPositionable.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/24/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameWorldPositionable: AnyObject {

    associatedtype GameWorldMember: GameWorldPositionable
    
    var world: GameWorld? { get }
    var position: Position { get set }

    var graphics: any GameWorldMemberGraphicsComponent<GameWorldMember> { get }
    
    func update(_ dt: Float)
    
    func removeFromWorld()
    
}

internal extension GameWorldPositionable {

    func inWorld() -> Bool {
        return world != nil
    }
    
}
