//
//  Position.swift
//  UselessEngine
//
//  Created by Manny Martins on 4/22/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public struct Position: PlaneCoordinate {
    
    public static let zero: Position = Position(x: 0.0, y: 0.0)
    
    public var x: Float
    public var y: Float
    public var z: Float
    
//    var position2d: Position2d {
//        return Position2d(x: x, y: y)
//    }

    public init(x: Float, y: Float, z: Float = 0.0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public mutating func add(b: Vector) {
        self.x += b.dx
        self.y += b.dy
        self.z += b.dz
    }
    
    public mutating func add(b: Vector, scaled scale: Float) {
        self.x += b.dx * scale
        self.y += b.dy * scale
        self.z += b.dz * scale
    }
    
    public func offset(toPosition position: Position) -> Vector {
        let offset = Vector(dx: self.x - position.x , dy: self.y - position.y, dz: self.z - position.z)
        return offset
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

public func +(lhs: Position, rhs: Vector) -> Position {
    return Position(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy, z: lhs.z + rhs.dz)
}

public func -(lhs: Position, rhs: Vector) -> Position {
    return Position(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy, z: lhs.z - rhs.dz)
}

extension Position: Equatable {}

public func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

public func !=(lhs: Position, rhs: Position) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
}
