//
//  GameObject.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/21/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public class GameObject: GameWorldMember, GameWorldObserverSubject {
    
    // MARK: - Properties

    internal private(set) static var inited: Int = 0

    public private(set) var state: GameObjectState?

    public let audio: GameObjectAudioComponent?
    public let physics: GameObjectPhysicsComponent
    public var input: GameObjectInputComponent?

    /// The object's velocity.
    public var velocity: Vector {
        didSet {
            if velocity != oldValue {
                velocityDidChange(from: oldValue)
            }
        }
    }
    
    // MARK: - Init
    
    public init(graphics graphicsComponent: GameWorldMemberGraphicsComponent,
                audio audioComponent: GameObjectAudioComponent? = nil,
                physics physicsComponent: GameObjectPhysicsComponent,
                input inputComponent: GameObjectInputComponent? = nil)
    {
        state = nil

        audio = audioComponent
        physics = physicsComponent
        input = inputComponent

        velocity = .zero
        
        super.init(graphics: graphicsComponent)

        add(observer: physics)
        
        // reset position for observers' sake
        position = .zero

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
    
    // MARK: - Update

    public override func onUpdate(_ dt: Float) {
        // update components
        physics.update(with: self, dt: dt)
        state?.update(with: self, dt: dt)
        input?.update(with: self, dt: dt)
        
        // resolve any collisions
        world?.collisionGrid.resolve(for: self)
    }
    
    // MARK: - State

    public func enter(state newState: GameObjectState) {
        state?.willExit(with: self)
        state = newState
        state?.enter(with: self)
        // call super to skip notification to self's state
        super.broadcast(event: .memberChange(with: .state))
    }
    
    public func push(state newState: GameObjectState) {
        let newState = newState
        newState.fallbackState = state
        state?.willFallback(with: self)
        state = newState
        state?.enter(with: self)
        // call super to skip notification to self's state
        super.broadcast(event: .memberChange(with: .state))
    }
    
    public func exitState() {
        state?.willExit(with: self)
        state = state?.fallbackState
        state?.reenter(with: self)
        // call super to skip notification to self's state
        super.broadcast(event: .memberChange(with: .state))
    }
    
    // MARK: - Events
    
    public override func broadcast(event: GameWorldMemberEvent, payload: Any? = nil) {
        state?.receive(event: event, from: self, payload: payload)
        super.broadcast(event: event, payload: payload)
    }

    private func velocityDidChange(from oldValue: Vector) {
        broadcast(event: .memberChange(with: .velocity), payload: oldValue)
    }
    
}
