//
//  GameObjectComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/20/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public protocol GameObjectSubcomponent: AnyObject {

    func update(with owner: GameObject, in world: GameWorld, dt: Float)

}
