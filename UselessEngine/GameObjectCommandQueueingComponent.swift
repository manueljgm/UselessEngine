//
//  GameObjectCommandQueueingComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/20/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public class GameObjectCommandQueueingComponent: GameObjectInputComponent
{
    public let id: UUID = UUID()
    
    /// Queued input commands.
    private var commandQueue: [GameObjectCommand] = []
    
    public init() {

    }

    public final func queue(command: GameObjectCommand)
    {
        if (command.priority == .urgent) {
            // if urgent, override all commands
            commandQueue = [command]
        } else {
            // else keep commands with higher priority than this command
            commandQueue = commandQueue.filter({ $0.priority > command.priority })
            // including the new one
            commandQueue.insert(command, at: 0)
        }
    }
    
    public func update(with gameObject: GameObject, dt: Float) {
        if let command = commandQueue.popLast() {
            gameObject.state?.handle(command: command, for: gameObject)
        }
    }
}
