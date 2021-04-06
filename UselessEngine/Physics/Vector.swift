//
//  Vector.swift
//  UselessEngine
//
//  Created by Manny Martins on 4/22/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public struct Vector {
    
    public static let zero: Vector = Vector(dx: .zero, dy: .zero, dz: .zero)
    
    public var dx: Float
    public var dy: Float
    public var dz: Float
    
    public var magnitude: Float {
        return sqrt(pow(dx, 2) + pow(dy, 2) + pow(dz, 2))
    }
    
    public var angle0: Float {
        return atan2(dy, dx)
    }
    
    public var angleZ: Float {
        return acos(dz / magnitude)
    }
    
    public subscript(component: GeometryComponent) -> Float {
        switch component {
        case .x:
            return dx
        case .y:
            return dy
        case .z:
            return dz
        }
    }
    
    public init(dx: Float, dy: Float, dz: Float = .zero) {
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
    
    public mutating func add(_ p: Position) {
        dx += p.x
        dy += p.y
        dz += p.z
    }

    public mutating func subtract(b: Vector) {
        dx -= b.dx
        dy -= b.dy
        dz -= b.dz
    }
    
    public mutating func scale(by scale: Float) {
        dx *= scale
        dy *= scale
        dz *= scale
    }
    
    public func scaled(by scale: Float) -> Vector {
        return Vector(dx: dx * scale, dy: dy * scale, dz: dz * scale)
    }
    
    public mutating func normalize() {
        let m = magnitude
        if m < 1e-12 {
            return
        }
        
        dx /= m
        dy /= m
        dz /= m
    }

    public func normalized() -> Vector {
        let m = magnitude
        if m < 1e-12 {
            return .zero
        }
        
        return Vector(dx: dx / m, dy: dy / m, dz: dz / m)
    }
    
    public func dot(b: Vector) -> Float {
        return dx * b.dx + dy * b.dy + dz * b.dz
    }
    
    public func theta(b: Vector) -> Float {
        return acos(normalized().dot(b: b.normalized())) * 180.0 / .pi
    }
    
    public func cross(b: Vector) -> Vector {
        return Vector(dx: dy * b.dz - dz * b.dy,
                      dy: dz * b.dx - dx * b.dz,
                      dz: dx * b.dy - dy * b.dx)
    }
    
}

public func +(lhs: Vector, rhs: Vector) -> Vector {
    return Vector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy, dz: lhs.dz + rhs.dz)
}

public func -(lhs: Vector, rhs: Vector) -> Vector {
    return Vector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy, dz: lhs.dz - rhs.dz)
}

extension Vector: Equatable {}

public func ==(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.dx == rhs.dx && lhs.dy == rhs.dy && lhs.dz == rhs.dz
}

public func !=(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.dx != rhs.dx || lhs.dy != rhs.dy || lhs.dz != rhs.dz
}
