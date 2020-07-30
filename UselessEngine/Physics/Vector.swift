//
//  Vector.swift
//  UselessEngine
//
//  Created by Manny Martins on 4/22/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public struct Vector { // TODO: PlaneVector
    
    public static let zero: Vector = Vector(dx: 0.0, dy: 0.0, dz: 0.0)
    
    public var dx: Float
    public var dy: Float
    public var dz: Float
    
    public var vector2d: Vector2d {
        return Vector2d(dx: dx, dy: dy)
    }
    
    public var isNonZero: Bool {
        return abs(dx) > 0.0 || abs(dy) > 0.0 || abs(dz) > 0.0
    }
    
    public var magnitude: Float {
        return sqrt(pow(dx, 2) + pow(dy, 2) + pow(dz, 2))
    }
    
    public var angle0: Float {
        return atan2(dy, dx)
    }
    
    public var angleZ: Float {
        return acos(dz / magnitude)
    }
    
    public var unit: Vector {
        let m = magnitude
        return Vector(dx: dx / m, dy: dy / m, dz: dz / m)
    }

    public init(dx: Float, dy: Float, dz: Float) {
        self.dx = dx
        self.dy = dy
        self.dz = dz
    }
  
    public init(angle0: Float, angleZ: Float, magnitude: Float) {
        self.dx = cos(angle0) * sin(angleZ) * magnitude
        self.dy = sin(angle0) * sin(angleZ) * magnitude
        self.dz = cos(angleZ) * magnitude
    }
    
    public mutating func add(b: Vector) {
        dx += b.dx
        dy += b.dy
        dz += b.dz
    }
    
    public mutating func add(b: Vector, scaled scale: Float) {
        dx += b.dx * scale
        dy += b.dy * scale
        dz += b.dz * scale
    }

    public mutating func scale(_ scale: Float)
    {
        let m = magnitude
        guard !m.isZero else {
            return
        }
        
        let newLength = m * scale
        let resizeFactor = newLength / m
        dx = dx * resizeFactor
        dy = dy * resizeFactor
        dz = dz * resizeFactor
    }
    
    public func scaled(by scale: Float) -> Vector
    {
        let m = magnitude
        guard !m.isZero else {
            return .zero
        }
        
        let newLength = m * scale
        let resizeFactor = newLength / m
        return Vector(dx: dx * resizeFactor, dy: dy * resizeFactor, dz: dz * resizeFactor)
    }
    
    public static func from(_ pointA: Position, to pointB: Position) -> Vector {
        return Vector(dx: pointB.x - pointA.x,
                      dy: pointB.y - pointA.y,
                      dz: pointB.z - pointA.z)
    }
    
}

extension Vector: Equatable {}

public func +(lhs: Vector, rhs: Vector) -> Vector {
    return Vector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy, dz: lhs.dz + rhs.dz)
}

public func ==(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.dx == rhs.dx && lhs.dy == rhs.dy && lhs.dz == rhs.dz
}

public func !=(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.dx != rhs.dx || lhs.dy != rhs.dy || lhs.dz != rhs.dz
}
