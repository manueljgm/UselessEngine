//
//  Vector2d.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/9/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import Foundation

public struct Vector2d: Codable {

    public static let zero: Vector2d = Vector2d(dx: 0.0, dy: 0.0)
    
    public var dx: Float
    public var dy: Float
    
    public var isNonZero: Bool {
        return abs(dx) > 0.0 || abs(dy) > 0.0
    }
    
    public var magnitude: Float {
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }
    
    public var angle: Float {
        return atan2(dy, dx)
    }
    
    public init(dx: Float, dy: Float) {
        self.dx = dx
        self.dy = dy
    }
    
    public init(angle: Float, magnitude: Float) {
        self.dx = cos(angle) * magnitude
        self.dy = sin(angle) * magnitude
    }

    public mutating func add(bx: Float, by: Float) {
        dx += bx
        dy += by
    }
    
    public mutating func add(b: Vector2d) {
        dx += b.dx
        dy += b.dy
    }
    
    public mutating func add(b: Vector2d, scaled scale: Float) {
        dx += b.dx * scale
        dy += b.dy * scale
    }
    
    public mutating func subtract(bx: Float, by: Float) {
        dx -= bx
        dy -= by
    }
    
    public mutating func subtract(b: Vector2d) {
        dx -= b.dx
        dy -= b.dy
    }
    
    public mutating func scale(_ scale: Float) {
        dx *= scale
        dy *= scale
    }
    
}

extension Vector2d: Equatable {}

public func +(lhs: Vector2d, rhs: Vector2d) -> Vector2d {
    return Vector2d(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
}

public func ==(lhs: Vector2d, rhs: Vector2d) -> Bool {
    return lhs.dx == rhs.dx && lhs.dy == rhs.dy
}

public func !=(lhs: Vector2d, rhs: Vector2d) -> Bool {
    return lhs.dx != rhs.dx || lhs.dy != rhs.dy
}
