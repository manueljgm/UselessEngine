//
//  GameObjectInputComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/25/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public protocol GameObjectInputComponent: AnyObject {

    func queue(command: GameObjectCommand, payload: AnyObject?)
    func update(with owner: GameObject, dt: Float)

}

