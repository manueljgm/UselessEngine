//
//  GameObjectUpdateable.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/24/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameObjectUpdateable {
    
    func update(with gameObject: GameObject, dt: Float)
    
}

extension GameObjectUpdateable {
    
    public func update(with gameObject: GameObject, dt: Float) {
        
    }
    
}
