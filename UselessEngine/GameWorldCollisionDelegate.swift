//
//  GameWorldCollisionDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/25/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public protocol GameWorldCollisionDelegate {

    func resolveCollision(on      gameObject: GameObject,
                          against otherObject: GameObject,
                          for     hit: Hit)
    -> (thisCorrection: Vector, otherCorrection: Vector)?
    
}
