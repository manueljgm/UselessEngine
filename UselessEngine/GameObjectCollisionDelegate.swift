//
//  GameObjectCollisionDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/24/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameObjectCollisionDelegate {
    
    func handleContact(between gameObject: GameObject,
                       and otherObject: GameObject,
                       in world: GameWorld)
    
    func handleCollision(between gameObject: GameObject,
                         and otherObject: GameObject,
                         withCorrection correctionOffset: Vector,
                         in world: GameWorld)
    
}

extension GameObjectCollisionDelegate {
    
    public func handleContact(between gameObject: GameObject,
                       and otherObject: GameObject,
                       in world: GameWorld) {
        
    }
    
    public func handleCollision(between gameObject: GameObject,
                         and otherObject: GameObject,
                         withCorrection correctionOffset: Vector,
                         in world: GameWorld) {
        
    }
    
}
