//
//  AABB.swift
//  UselessEngine
//
//  Created by Manny Martins on 2/12/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public struct AABB {
    
    /// AABB position
    public var position: Position {
        didSet {
            self.centerPosition = Position(
                x: self.centerPosition.x + (self.position.x - oldValue.x),
                y: self.centerPosition.y + (self.position.y - oldValue.y),
                z: self.centerPosition.z + (self.position.z - oldValue.z)
            )
        }
    }
    
    /// AABB halfwidths
    public private(set) var halfwidths: Vector
    
    /// AABB anchor position
    public var anchorPosition: Vector {
        didSet {
            updateCenterPosition()
        }
    }
    
    public private(set) var centerPosition: Position!
    
    public init(position: Position = Position.zero,
                halfwidths: Vector,
                anchorPosition: Vector = Vector(dx: 0.5, dy: 0.5, dz: 0.5)) {
            
            self.position = position
            self.halfwidths = halfwidths
            self.anchorPosition = anchorPosition
            
            updateCenterPosition()
    }
    
    public func intersect(_ otherAABB: AABB, withTolerance tolerance: Float = 0.0) -> Hit? {
        let dx = otherAABB.centerPosition.x - self.centerPosition.x
        let px = (self.halfwidths.dx + otherAABB.halfwidths.dx) - abs(dx)
        if px < tolerance {
            return nil
        }
        
        let dy = otherAABB.centerPosition.y - self.centerPosition.y
        let py = (self.halfwidths.dy + otherAABB.halfwidths.dy) - abs(dy)
        if py < tolerance {
            return nil
        }
        
        let dz = otherAABB.centerPosition.z - self.centerPosition.z
        let pz = (self.halfwidths.dz + otherAABB.halfwidths.dz) - abs(dz)
        if pz < tolerance {
            return nil
        }
        
        let sx: Float = dx < 0 ? -1 : 1
        let sy: Float = dy < 0 ? -1 : 1
        let hit = Hit(delta: Vector2d(dx: px * sx, dy: py * sy),
                      normal: Vector2d(dx: sy, dy: sy))
        return hit
    }
    
    private mutating func updateCenterPosition() {
        centerPosition = Position(
            x: self.position.x + (2.0 * (0.5 - self.anchorPosition.dx) * self.halfwidths.dx),
            y: self.position.y + (2.0 * (0.5 - self.anchorPosition.dy) * self.halfwidths.dy),
            z: self.position.z + (2.0 * (0.5 - self.anchorPosition.dz) * self.halfwidths.dz)
        )
    }
    
}
