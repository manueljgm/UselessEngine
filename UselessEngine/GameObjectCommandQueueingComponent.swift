//
//  GameObjectCommandQueueingComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/20/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

open class GameObjectCommandQueueingComponent: GameObjectInputComponent {

    /// Queued input commands.
    public private(set) var commandQueue: [(command: GameObjectCommand, payload: AnyObject?)] = []
    
    public init() {

    }

    public func queue(command: GameObjectCommand, payload: AnyObject?) {
        if (command.priority == .urgent) {
            // if urgent, override all commands
            commandQueue = [(command, payload)]
        } else {
            // else keep commands with higher priority than this command
            commandQueue = commandQueue.filter({ $0.command.priority > command.priority })
            // including the new one
            commandQueue.insert((command, payload), at: 0)
        }
    }
    
    open func update(with gameObject: GameObject, dt: Float) {
        if let tuple = commandQueue.popLast() {
            gameObject.state?.handle(command: tuple.command, on: gameObject, payload: tuple.payload)
        }
    }
    
}
