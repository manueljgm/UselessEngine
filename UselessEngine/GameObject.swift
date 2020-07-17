//
//  GameObject.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/21/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

open class GameObject: GameEntity {
    
    // MARK: - Properties
    
    public var state: GameObjectState?
    // TODO: private(set) var otherState: GameObjectState? // e.g. equipment, invincibility
    
    public let graphics: GameEntityGraphicsComponent?
    public let physics: GameObjectPhysicsComponent?
    public let input: GameObjectInputComponent?
    
    public var position: Position {
        didSet {
            if (self.position != oldValue) {
                positionDidChange(from: oldValue)
            }
        }
    }
    
    public var velocity: Vector {
        didSet {
            if (self.velocity != oldValue) {
                velocityDidChange(from: oldValue)
            }
        }
    }
    
    // MARK: Init
    
    public init(graphics graphicsComponent: GameEntityGraphicsComponent? = nil, physics physicsComponent: GameObjectPhysicsComponent? = nil, input inputComponent: GameObjectInputComponent? = nil) {
        state = nil
        graphics = graphicsComponent
        physics = physicsComponent
        input = inputComponent
        position = Position.zero
        velocity = Vector.zero
    }
    
    // MARK: Update
    
    public func update(_ dt: Float) {
        input?.update(with: self, dt: dt)
        state?.update(with: self, dt: dt)
        physics?.update(with: self, dt: dt)
        graphics?.update(with: self, dt: dt)
    }
    
    // MARK: State

    public func enter(state newState: GameObjectState) {
        state = newState
        state?.enter(with: self)
    }
    
    // MARK: Events
    
    private func positionDidChange(from previousPosition: Position) {
        graphics?.positionDidUpdate(from: previousPosition, for: self)
        physics?.positionDidChange(from: previousPosition, for: self)
        state?.receive(PhysicsEvent.positionDidChange, from: self, payload: previousPosition)
    }
    
    private func velocityDidChange(from previousVelocity: Vector) {
        state?.receive(PhysicsEvent.velocityDidChange, from: self, payload: previousVelocity)
    }
    
}

// MARK: - GameObject: Subject

//extension GameObject: Subject {
//
//    func broadcast<TPayload>(event: Event, payload: TPayload) {
//
//        self.observers.receive(event: event, from: self, payload: payload)
//
//    }
//
//}
