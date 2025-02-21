//
//  GameObjectCommand.swift
//  UselessEngine
//
//  Created by Manny Martins on 6/18/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

import Foundation

public enum GameObjectCommandPriority: Comparable {
    case low
    case medium
    case high
    case urgent
}

public struct GameObjectCommand: Identifiable {
    
    public let id: UUID = UUID()
    public let priority: GameObjectCommandPriority

    public init(priority: GameObjectCommandPriority) {
        self.priority = priority
    }
    
}

extension GameObjectCommand: Equatable {
    
    public static func == (lhs: GameObjectCommand, rhs: GameObjectCommand) -> Bool {
        return lhs.id == rhs.id
    }
    
}
