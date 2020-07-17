//
//  GameObjectComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/20/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public protocol GameObjectComponent: class {
    func update(with owner: GameObject, dt: Float)
}
