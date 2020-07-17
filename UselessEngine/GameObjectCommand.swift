//
//  GameObjectCommand.swift
//  UselessEngine
//
//  Created by Manny Martins on 6/18/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

import Foundation

public enum GameObjectCommandPriority: UInt8 {
    case high   = 1
    case medium = 2
    case low    = 3
}

public class GameObjectCommand {
    
    public let priority: GameObjectCommandPriority
    
    private var action: ((GameObject) -> Void)? = nil
    
    public init(priority: GameObjectCommandPriority) {
        self.priority = priority
    }

    public convenience init(priority: GameObjectCommandPriority, action: @escaping (GameObject) -> Void) {
        self.init(priority: priority)
        self.action = action
    }
    
    public func doBundledAction(toGameObject gameObject: GameObject) {
        if let action = self.action {
            action(gameObject)
        }
    }
    
//    func undo() {
//        
//    }
    
}

extension GameObjectCommand: Equatable {}

public func ==(lhs: GameObjectCommand, rhs: GameObjectCommand) -> Bool {
    return lhs === rhs
}

public func !=(lhs: GameObjectCommand, rhs: GameObjectCommand) -> Bool {
    return lhs !== rhs
}
