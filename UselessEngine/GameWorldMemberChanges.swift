//
//  GameWorldMemberChanges.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/21/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public struct GameWorldMemberChanges: OptionSet {

    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none = GameWorldMemberChanges([])
    public static let state = GameWorldMemberChanges(rawValue: 1 << 0)
    public static let position = GameWorldMemberChanges(rawValue: 1 << 1)
    public static let velocity = GameWorldMemberChanges(rawValue: 1 << 2)

}
