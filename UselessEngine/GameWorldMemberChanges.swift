//
//  GameWorldMemberChanges.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/21/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public struct GameWorldMemberChanges: OptionSet {

    public let rawValue: Int
    
    public static let none = GameWorldMemberChanges([])
    public static let state = GameWorldMemberChanges.createFlag()
    public static let position = GameWorldMemberChanges.createFlag()
    public static let velocity = GameWorldMemberChanges.createFlag()
    
    private static var nextFlagIndex: Int = 0
    private static var maxFlagIndex: Int = 63
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static func createFlag() -> GameWorldMemberChanges {
        guard nextFlagIndex <= maxFlagIndex else {
            return .none
        }
        
        defer {
            nextFlagIndex += 1
        }
        
        return GameWorldMemberChanges(rawValue: 1 << nextFlagIndex)
    }

}
