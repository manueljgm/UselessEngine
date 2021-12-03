//
//  GameWorldUpdateable.swift
//  UselessEngine
//
//  Created by Manny Martins on 8/24/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameWorldUpdateable {
    
    func update(with gameObject: GameObject, dt: Float)
    
}

extension GameWorldUpdateable {
    
    public func update(with gameObject: GameObject, dt: Float) {
        
    }
    
}
