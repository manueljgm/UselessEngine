//
//  GameObjectThrustComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/23/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameObjectThrustComponent: GameObjectUpdateable, AnyObject {
    
    var value: Vector { get set }

}
