//
//  Position2d.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/13/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public struct Position2d: PlaneCoordinate {
    
    public static let zero: Position2d = Position2d(x: .zero, y: .zero)

    public var x: Float
    public var y: Float

    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }

    public mutating func add(b: Vector2d) {
        x += b.dx
        y += b.dy
    }
    
    public mutating func add(b: Vector2d, scaled scale: Float) {
        x += b.dx * scale
        y += b.dy * scale
    }
    
    public func distance(to position: Position2d) -> Vector2d {
        return Vector2d(dx: position.x - x, dy: position.y - y)
    }
    
}

public func +(lhs: Position2d, rhs: Position2d) -> Position2d {
    return Position2d(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: Position2d, rhs: Position2d) -> Position2d {
    return Position2d(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

extension Position2d: Equatable {}

public func ==(lhs: Position2d, rhs: Position2d) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

public func !=(lhs: Position2d, rhs: Position2d) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y
}
