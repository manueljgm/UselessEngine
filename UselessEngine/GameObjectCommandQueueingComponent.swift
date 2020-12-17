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
            // override all commands
            commandQueue.removeAll(keepingCapacity: true)
        } else {
            // override commands with same or lower priority than this command
            for i in stride(from: (commandQueue.count - 1), through: 0, by: -1) {
                if commandQueue[i].priority <= command.priority {
                    commandQueue.remove(at: i)
                }
            }
        }
        
        commandQueue.insert(command, at: 0)
    }
    
    public func update(with gameObject: GameObject, dt: Float) {
        dequeueAndDoCommand(with: gameObject)
    }
    
    private func dequeueAndDoCommand(with gameObject: GameObject) {
        if let command = commandQueue.popLast() {
            gameObject.state?.handle(command: command, for: gameObject)
        }
    }
}
