//
//  GameWorldCollisionHandler.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/25/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public protocol GameWorldCollisionHandler {
    func resolveBounds(onGameObject testObject: GameObject, previouslyAt previousPosition: Position, in gameWorld: GameWorld)
    func resolveCollisions(onGameObject testObject: GameObject, in gameWorld: GameWorld)
}
