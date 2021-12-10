//
//  GameObject.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/21/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public class GameObject: GameWorldMember, GameWorldObserverSubject {
    
    // MARK: - Properties
    
    private static var inited: Int = 0

    public internal(set) weak var parent: GameWorldMember?
    
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

    private var changes: GameWorldMemberChanges = []
    
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

    public override func update(_ dt: Float) -> GameWorldMemberChanges {
        // update components
        physics.update(with: self, dt: dt)
        graphics.update(with: self, dt: dt)
        state?.update(with: self, dt: dt)
        input?.update(with: self, dt: dt)

        defer {
            // clear the change tracker once out of this update scope
            changes = .none
        }
        return changes
    }
    
    public func removeFromParent() {
        parent?.children.remove(self)
        parent = nil
    }

    // MARK: - State

    public func enter(state newState: GameObjectState) {
        state?.willExit(with: self)
        state = newState
        state?.enter(with: self)
        changes.insert(.state)
        observers.objectEnumerator().forEach { observer in
            (observer as? GameWorldMemberObserver)?.receive(event: .memberChange(with: .state), from: self, payload: nil)
        }
    }
    
    public func push(state newState: GameObjectState) {
        let newState = newState
        newState.fallbackState = state
        enter(state: newState)
    }
    
    public func exitState() {
        state?.willExit(with: self)
        state = state?.fallbackState
        state?.reenter(with: self)
        changes.insert(.state)
        observers.objectEnumerator().forEach { observer in
            (observer as? GameWorldMemberObserver)?.receive(event: .memberChange(with: .state), from: self, payload: nil)
        }
    }
    
    // MARK: - Events
    
    override public func broadcast(event: GameWorldMemberEvent, payload: Any? = nil) {
        state?.receive(event: event, from: self, payload: payload)
        super.broadcast(event: event, payload: payload)
    }
    
    internal override func positionDidChange(from oldValue: Position) {
        changes.insert(.position)
        super.positionDidChange(from: oldValue)
    }
    
    private func velocityDidChange(from oldValue: Vector) {
        changes.insert(.velocity)
        broadcast(event: .memberChange(with: .velocity), payload: oldValue)
    }
    
}
