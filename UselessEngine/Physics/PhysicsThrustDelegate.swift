//
//  PhysicsThrustDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/23/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol PhysicsThrustDelegate: AnyObject {
    
    var thrust: Vector { get set }
    var boost: Boost? { get set }

    func setDrag(to coefficient: Float)
    
    func update(with gameObject: GameObject, in world: GameWorld, dt: Float)

}

extension PhysicsThrustDelegate {
    
    func update(with gameObject: GameObject, in world: GameWorld, dt: Float) {
        
    }
    
}
