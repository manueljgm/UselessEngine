//
//  GameObjectCommandComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/20/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

open class GameObjectCommandComponent: GameObjectInputComponent { // TODO: Consider renaming this class to a name more reflective of the function
    
    private var commandQueue: [GameObjectCommand] = []
    
    public init() {
        
    }
    
    public final func queue(command: GameObjectCommand) {
        if (command.priority == .high) {
            // override all commands
            self.commandQueue.removeAll(keepingCapacity: true)
        } else {
            // override commands with same or lower priority than this command
            for i in stride(from: (self.commandQueue.count - 1), through: 0, by: -1) {
                if self.commandQueue[i].priority.rawValue >= command.priority.rawValue {
                    commandQueue.remove(at: i)
                }
            }
        }
        
        self.commandQueue.insert(command, at: 0)
    }
    
    open func update(with gameObject: GameObject, dt: Float) {
        dequeueAndDoCommand(with: gameObject)
    }
    
    private func dequeueAndDoCommand(with gameObject: GameObject) {
        if let command = commandQueue.popLast() {
            gameObject.state?.handle(command: command, for: gameObject)
        }
    }
    
}
