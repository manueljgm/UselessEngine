//
//  GameObjectCommand.swift
//  UselessEngine
//
//  Created by Manny Martins on 6/18/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public enum GameObjectCommandPriority: Comparable
{
    case low
    case medium
    case high
    case urgent
}

public struct GameObjectCommand: Identifiable
{
    public let id: UUID = UUID()
    public let priority: GameObjectCommandPriority
    
    private var action: ((GameObject) -> Void)? = nil
    
    public init(priority: GameObjectCommandPriority) {
        self.priority = priority
    }

    public init(priority: GameObjectCommandPriority, action: @escaping (GameObject) -> Void) {
        self.init(priority: priority)
        self.action = action
    }
    
    public func doBundledAction(toGameObject gameObject: GameObject) {
        if let action = action {
            action(gameObject)
        }
    }
}

extension GameObjectCommand: Equatable
{
    public static func == (lhs: GameObjectCommand, rhs: GameObjectCommand) -> Bool {
        return lhs.id == rhs.id
    }
}
