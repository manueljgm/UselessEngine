//
//  GameObjectInputComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/25/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public protocol GameObjectInputComponent: class {

    var id: UUID { get }

    func queue(command: GameObjectCommand)
    func update(with owner: GameObject, dt: Float)

}

