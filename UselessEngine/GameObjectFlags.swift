//
//  GameObjectFlags.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/31/23.
//  Copyright © 2023 Useless Robot. All rights reserved.
//

public struct GameObjectFlags: OptionSet {

    public let rawValue: Int
    
    public static let none = GameObjectFlags([])
    internal static let positionDidUpdate = createFlag()
    
    private static var nextFlagIndex: Int = 0
    private static var maxFlagIndex: Int = 63
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static func createFlag() -> GameObjectFlags {
        guard nextFlagIndex <= maxFlagIndex else {
            return .none
        }
        
        defer {
            nextFlagIndex += 1
        }
        
        return GameObjectFlags(rawValue: 1 << nextFlagIndex)
    }
    
}
