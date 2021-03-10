//
//  Ray.swift
//  UselessEngine
//
//  Created by Manny Martins on 2/4/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public struct Ray {
    
    public let position: Position
    public let direction: Vector
    
    public init(position: Position, direction: Vector) {
        self.position = position
        self.direction = direction
    }
    
}


