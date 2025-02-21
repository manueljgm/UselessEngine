//
//  GameObjectCommandQueueingComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/20/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import Foundation

public class GameObjectCommandQueueingComponent: GameObjectInputComponent {

    /// Queued input commands.
    public private(set) var commandQueue: [(command: GameObjectCommand, ts: TimeInterval, payload: AnyObject?)] = []
    
    public init() {

    }

    public func queue(command newCommand: GameObjectCommand, payload: AnyObject?) {
        if (newCommand.priority == .urgent) {
            // if urgent, override all commands
            commandQueue = [(newCommand, Date.timeIntervalSinceReferenceDate, payload)]
        } else {
            // clear any previous calls to the same command
            commandQueue.removeAll(where: { $0.command == newCommand })
            // and add the new command
            commandQueue.append((newCommand, Date.timeIntervalSinceReferenceDate, payload))
            // finally sort by priority and then timestamp
            commandQueue.sort {
                guard $0.command.priority != $1.command.priority else {
                    return $0.ts > $1.ts
                }
                return $0.command.priority < $1.command.priority
            }
        }
    }
    
    public func update(with gameObject: GameObject, dt: Float) {
        if let tuple = commandQueue.popLast() {
            gameObject.state?.handle(command: tuple.command, on: gameObject, payload: tuple.payload)
        }
    }
    
}
