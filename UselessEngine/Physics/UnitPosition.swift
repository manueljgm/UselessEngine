//
//  UnitPosition.swift
//  UselessEngine
//
//  Created by Manny Martins on 6/6/17.
//  Copyright © 2017 Useless Robot. All rights reserved.
//

public enum UnitPositionError: Error {
    case unitPositionComponentMaxExceeded
}

public struct UnitPosition: Hashable {
    
    public static let zero: UnitPosition = UnitPosition(x: 0, y: 0)
    public static let componentMax: Int = Int(Int16.max)
    
    public let x: Int
    public let y: Int
    
    public init(x: Int, y: Int) {
        assert(abs(x) <= UnitPosition.componentMax && abs(y) <= UnitPosition.componentMax, "Unit position component value exceeded preset maximum.")
        self.x = x
        self.y = y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
}

public func ==(lhs: UnitPosition, rhs: UnitPosition) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public func !=(lhs: UnitPosition, rhs: UnitPosition) -> Bool {
    return lhs.hashValue != rhs.hashValue
}

