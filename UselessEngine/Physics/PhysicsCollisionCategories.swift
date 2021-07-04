//
//  PhysicsCollisionCategories.swift
//  UselessEngine
//
//  Created by Manny Martins on 3/3/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public struct PhysicsCollisionCategories : OptionSet {

    public let rawValue: UInt
    public var boolValue: Bool { return self.rawValue > 0 }
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let none = PhysicsCollisionCategories([])
    public static let all = PhysicsCollisionCategories(rawValue: UInt.max)

}
