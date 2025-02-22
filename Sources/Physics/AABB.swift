//
//  AABB.swift
//  UselessEngine
//
//  Created by Manny Martins on 2/12/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public struct AABB: Codable {
    
    /// AABB position
    public var position: Position {
        didSet {
            updateRelativePositions()
        }
    }
    
    /// AABB halfwidths
    public var halfwidths: Vector {
        didSet {
            updateRelativePositions()
        }
    }
    
    /// AABB anchor position
    public var anchorPosition: Vector {
        didSet {
            updateRelativePositions()
        }
    }
    
    public private(set) var center: Position!
    public private(set) var minimum: Position!
    public private(set) var maximum: Position!
    
    private static let epsilon: Float = 1e-6
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        position = try container.decode(Position.self, forKey: .position)
        halfwidths = try container.decode(Vector.self, forKey: .halfwidths)
        anchorPosition = try container.decode(Vector.self, forKey: .anchorPosition)
        
        updateRelativePositions()
    }
    
    public init(position: Position = .zero,
                halfwidths: Vector,
                anchorPosition: Vector = Vector(dx: 0.5, dy: 0.5, dz: 0.5)) {
            
        self.position = position
        self.halfwidths = halfwidths
        self.anchorPosition = anchorPosition
            
        updateRelativePositions()
    }
    
    public func minkowskiDifference(_ otherAABB: AABB) -> AABB {
        let mdHalfwidths = halfwidths + otherAABB.halfwidths
        let mdPosition = Position(x: minimum.x - otherAABB.maximum.x + mdHalfwidths.dx,
                                  y: minimum.y - otherAABB.maximum.y + mdHalfwidths.dy,
                                  z: minimum.z - otherAABB.maximum.z + mdHalfwidths.dz)
        return AABB(position: mdPosition, halfwidths: mdHalfwidths)
    }
    
    public func contains(_ point: Position) -> Bool {
        if point.x < minimum.x || point.x > maximum.x {
            return false
        }
        
        if point.y < minimum.y || point.y > maximum.y {
            return false
        }
        
        if point.z < minimum.z || point.z > maximum.z {
            return false
        }
        
        return true
    }
    
    public func intersect(_ otherAABB: AABB) -> Hit? {
        let dx = otherAABB.center.x - center.x
        let px = (halfwidths.dx + otherAABB.halfwidths.dx) - abs(dx)
        if px < AABB.epsilon {
            return nil
        }
        
        let dy = otherAABB.center.y - center.y
        let py = (halfwidths.dy + otherAABB.halfwidths.dy) - abs(dy)
        if py < AABB.epsilon {
            return nil
        }
        
        let dz = otherAABB.center.z - center.z
        let pz = (halfwidths.dz + otherAABB.halfwidths.dz) - abs(dz)
        if pz < AABB.epsilon {
            return nil
        }
        
        let sx: Float = dx < 0 ? -1 : 1
        let sy: Float = dy < 0 ? -1 : 1
        let hit = Hit(delta: Vector2d(dx: px * sx, dy: py * sy),
                      normal: Vector2d(dx: sy, dy: sy))
        return hit
    }
    
    public func intersect(_ ray: Ray, ignoringZ ignoreZ: Bool = false) -> Vector? {
        var tNear = -Float.infinity
        var tFar = Float.infinity

        if !intersect(ray, onAxis: .x, &tNear, &tFar) { return nil }
        if !intersect(ray, onAxis: .y, &tNear, &tFar) { return nil }
        if !ignoreZ && !intersect(ray, onAxis: .z, &tNear, &tFar) { return nil }

        let t = (tNear < 0 || tFar < 0) ? max(tNear, tFar) : min(tNear, tFar)

        var result = ray.direction
        result.scale(by: t)
        result.add(ray.position)
        
        return result
    }
    
    // MARK: - Helper Methods
    
    private mutating func updateRelativePositions() {
        center = Position(x: position.x + (halfwidths.dx * 2.0 * (0.5 - anchorPosition.dx)),
                          y: position.y + (halfwidths.dy * 2.0 * (0.5 - anchorPosition.dy)),
                          z: position.z + (halfwidths.dz * 2.0 * (0.5 - anchorPosition.dz)))

        minimum = Position(x: center.x - halfwidths.dx,
                           y: center.y - halfwidths.dy,
                           z: center.z - halfwidths.dz)

        maximum = Position(x: center.x + halfwidths.dx,
                           y: center.y + halfwidths.dy,
                           z: center.z + halfwidths.dz)
    }
    
    private func intersect(_ ray: Ray, onAxis component: GeometryComponent, _ tNear: inout Float, _ tFar: inout Float) -> Bool {
        var t1: Float = .zero,
            t2: Float = .zero
        
        if ray.direction[component] == .zero {
            if ray.position[component] < minimum[component] || ray.position[component] > maximum[component] {
                return false
            }
        } else {
            t1 = (minimum[component] - ray.position[component]) / ray.direction[component]
            t2 = (maximum[component] - ray.position[component]) / ray.direction[component]

            if t1 > t2 {
                let swap = t1
                t1 = t2
                t2 = swap
            }

            if t1 > tNear {
                tNear = t1
            }

            if t2 < tFar {
                tFar = t2
            }

            if tNear > tFar {
                return false
            }

            if tFar < 0 {
                return false
            }
        }

        return true
    }
    
}
