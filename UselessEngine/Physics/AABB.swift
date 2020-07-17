//
//  AABB.swift
//  UselessEngine
//
//  Created by Manny Martins on 2/12/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public class AABB {
    
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
    
    public func intersects(with otherAABB: AABB) -> Hit? {
        let dx = otherAABB.centerPosition.x - self.centerPosition.x
        let px = (self.halfwidths.dx + otherAABB.halfwidths.dx) - abs(dx)
        if px <= 0.0 {
            return nil
        }
        
        let dy = otherAABB.centerPosition.y - self.centerPosition.y
        let py = (self.halfwidths.dy + otherAABB.halfwidths.dy) - abs(dy)
        if py <= 0.0 {
            return nil
        }
        
        let dz = otherAABB.centerPosition.z - self.centerPosition.z
        let pz = (self.halfwidths.dz + otherAABB.halfwidths.dz) - abs(dz)
        if pz <= 0.0 {
            return nil
        }
        
        if px < py {
            let sx: Float = dx < 0 ? -1 : 1
            return Hit(delta: Vector2d(dx: px * sx, dy: 0.0),
                       normal: Vector2d(dx: sx, dy: 0.0),
                       position: Position2d(x: self.centerPosition.x + (self.halfwidths.dx * sx), y: otherAABB.centerPosition.y))
        } else {
            let sy: Float = dy < 0 ? -1 : 1
            return Hit(delta: Vector2d(dx: 0, dy: py * sy),
                       normal: Vector2d(dx: 0, dy: sy),
                       position: Position2d(x: otherAABB.centerPosition.x, y: self.centerPosition.y + (self.halfwidths.dy * sy)))
        }
    }
    
    private func updateCenterPosition() {
        self.centerPosition = Position(
            x: self.position.x + (2.0 * (0.5 - self.anchorPosition.dx) * self.halfwidths.dx),
            y: self.position.y + (2.0 * (0.5 - self.anchorPosition.dy) * self.halfwidths.dy),
            z: self.position.z + (2.0 * (0.5 - self.anchorPosition.dz) * self.halfwidths.dz)
        )
    }
    
}
