//
//  Position.swift
//  UselessEngine
//
//  Created by Manny Martins on 4/22/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public struct Position: PlaneCoordinate {
    
    public static let zero: Position = Position(x: .zero, y: .zero)
    
    public var x: Float
    public var y: Float
    public var z: Float
    
    public subscript(component: GeometryComponent) -> Float {
        switch component {
        case .x:
            return x
        case .y:
            return y
        case .z:
            return z
        }
    }
    
    public init(x: Float, y: Float, z: Float = .zero) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public mutating func add(b: Vector) {
        x += b.dx
        y += b.dy
        z += b.dz
    }
    
    public mutating func add(b: Vector, scaled scale: Float) {
        x += b.dx * scale
        y += b.dy * scale
        z += b.dz * scale
    }
    
    public mutating func subtract(b: Vector) {
        x -= b.dx
        y -= b.dy
        z -= b.dz
    }
    
}

public func +(lhs: Position, rhs: Position) -> Vector {
    return Vector(dx: lhs.x + rhs.x, dy: lhs.y + rhs.y, dz: lhs.z + rhs.z)
}

public func -(lhs: Position, rhs: Position) -> Vector {
    return Vector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y, dz: lhs.z - rhs.z)
}

public func +(lhs: Position, rhs: PlaneCoordinate) -> Position {
    return Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: Position, rhs: PlaneCoordinate) -> Position {
    return Position(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func +(lhs: PlaneCoordinate, rhs: Position) -> Position {
    return Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: PlaneCoordinate, rhs: Position) -> Position {
    return Position(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

extension Position: Equatable {}

public func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

public func !=(lhs: Position, rhs: Position) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
}
