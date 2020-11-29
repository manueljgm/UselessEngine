//
//  GameObject.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/21/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

open class GameObject: GameEntity, Identifiable
{
    // MARK: - Properties
    
    public let id: UUID = UUID()
    
    public var state: GameObjectState?

    public let graphics: GameEntityGraphicsComponent?
    public let physics: GameObjectPhysicsComponent?
    public let input: GameObjectInputComponent?
    
    /// The object's position.
    public var position: Position {
        didSet {
            if (position != oldValue) {
                graphics?.receive(event: .positionChange, from: self)
                physics?.receive(event: .positionChange, from: self)
                state?.receive(.positionChange, from: self, payload: oldValue)
            }
        }
    }
    
    /// The object's velocity.
    public var velocity: Vector {
        didSet {
            if (velocity != oldValue) {
                state?.receive(.velocityChange, from: self, payload: oldValue)
            }
        }
    }
    
    private static var inited: Int = 0
    
    // MARK: Init
    
    public init(graphics graphicsComponent: GameEntityGraphicsComponent? = nil, physics physicsComponent: GameObjectPhysicsComponent? = nil, input inputComponent: GameObjectInputComponent? = nil)
    {
        state = nil
        graphics = graphicsComponent
        physics = physicsComponent
        input = inputComponent
        position = .zero
        velocity = .zero
        
        GameObject.inited += 1
        #if DEBUG_VERBOSE
        print(String(format: "GameObject:init; %d exist", GameObject.inited))
        #endif
    }
    
    deinit {
        GameObject.inited -= 1
        #if DEBUG_VERBOSE
        print(String(format: "GameObject:deinit; %d remain", GameObject.inited))
        #endif
    }
    
    // MARK: Update
    
    public func update(_ dt: Float) -> GameEntityChanges
    {
        let previousPosition = position
        let previousVelocity = velocity
        
        input?.update(with: self, dt: dt)
        state?.update(with: self, dt: dt)
        physics?.update(with: self, dt: dt)
        graphics?.update(with: self, dt: dt)
        
        var changes: GameEntityChanges = []
        if position != previousPosition {
            changes.insert(.position)
        }
        if velocity != previousVelocity {
            changes.insert(.velocity)
            
        }
        return changes
    }
    
    // MARK: State

    public func enter(state newState: GameObjectState) {
        state = newState
        state?.enter(with: self)
    }

}

extension GameObject: Equatable {
    public static func == (lhs: GameObject, rhs: GameObject) -> Bool {
        return lhs.id == rhs.id
    }
}
