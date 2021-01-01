//
//  GameWorldCollisionDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/25/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public protocol GameWorldCollisionDelegate {

    func resolveBoundaries(on gameObject: GameObject, in world: GameWorld)
    func resolveCollisions(on gameObject: GameObject, in world: GameWorld) -> [GameObject]

}
