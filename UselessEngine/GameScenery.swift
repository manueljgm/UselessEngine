//
//  GameScenery.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/16/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public final class GameScenery: GameEntity {
    
    public var graphics: GameEntityGraphicsComponent?
    
    public var position: Position
    
    public init(graphics: GameEntityGraphicsComponent) {
        self.graphics = graphics
        self.position = .zero
    }
    
    public func update(_ dt: Float) {
        
    }
    
}

