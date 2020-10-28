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
                positionDidChange(from: oldValue)
            }
        }
    }
    
    /// The object's velocity without added boost.
    public var velocity: Vector {
        didSet {
            if (velocity != oldValue) {
                velocityDidChange(from: oldValue)
            }
        }
    }
    
    /// The object's velocity plus any added boost.
    public var totalVelocity: Vector {
        get {
            return velocity + (physics?.boost?.velocity ?? .zero)
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
        state?.receive(.positionChange, from: self, payload: previousPosition)
    }
    
    private func velocityDidChange(from previousVelocity: Vector) {
        state?.receive(.velocityChange, from: self, payload: previousVelocity)
    }
}

extension GameObject: Equatable {
    public static func == (lhs: GameObject, rhs: GameObject) -> Bool {
        return lhs.id == rhs.id
    }
}
