//
//  GameObject.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/21/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public class GameObject: GameWorldMember
{
    // MARK: - Properties

    private static var inited: Int = 0
    
    public private(set) var state: GameObjectState?

    public let graphics: GameWorldMemberGraphicsComponent
    public let physics: GameObjectPhysicsComponent?
    public var input: GameObjectInputComponent?
    
    /// The object's position.
    public var position: Position {
        didSet {
            if (position != oldValue) {
                graphics.receive(event: .memberChange(with: .position), from: self, payload: oldValue)
                physics?.receive(event:.memberChange(with: .position), from: self, payload: oldValue)
                state?.receive(event: .memberChange(with: .position), from: self, payload: oldValue)
                changes.insert(.position)
            }
        }
    }
    
    /// The object's velocity.
    public var velocity: Vector {
        didSet {
            if (velocity != oldValue) {
                state?.receive(event: .memberChange(with: .velocity), from: self, payload: oldValue)
                changes.insert(.velocity)
            }
        }
    }
    
    private var changes: GameWorldMemberChanges = []
    
    // MARK: Init
    
    public init(graphics graphicsComponent: GameWorldMemberGraphicsComponent,
                physics physicsComponent: GameObjectPhysicsComponent? = nil,
                input inputComponent: GameObjectInputComponent? = nil)
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

    public func update(_ dt: Float, in world: GameWorld) -> GameWorldMemberChanges
    {
        input?.update(with: self, dt: dt)
        state?.update(with: self, in: world, dt: dt)
        physics?.update(with: self, in: world, dt: dt)
        graphics.update(with: self, dt: dt)

        defer {
            changes = .none
        }
        return changes
    }
    
    // MARK: State

    public func enter(state newState: GameObjectState) {
        state = newState
        state?.enter(with: self)
        changes.insert(.state)
    }
    
    public func push(state newState: GameObjectState) {
        var newState = newState
        newState.fallbackState = state
        enter(state: newState)
        changes.insert(.state)
    }
    
    public func exitState() {
        state = state?.fallbackState
        state?.reset(with: self)
        changes.insert(.state)
    }
}

extension GameObject: Equatable {
    
    public static func == (lhs: GameObject, rhs: GameObject) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
}

extension GameObject: Hashable {

    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self))
    }
    
}
