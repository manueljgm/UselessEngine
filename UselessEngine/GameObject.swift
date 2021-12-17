//
//  GameObject.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/21/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

import UIKit

public class GameObject: GameWorldMember, GameWorldObserverSubject {
    
    // MARK: - Properties

    internal private(set) static var inited: Int = 0
    
    public internal(set) weak var parent: GameWorldMember? {
        didSet {
            if parent != oldValue {
                parentDidChange(from: oldValue)
            }
        }
    }
    
    public private(set) var state: GameObjectState?

    public let audio: GameObjectAudioComponent?
    public let physics: GameObjectPhysicsComponent
    public var input: GameObjectInputComponent?
    
    /// The object's relative position to its parent.
    public var relativePosition: Position {
        get {
            return _relativePosition
        }
        set {
            if newValue != _relativePosition {
                let oldValue = _relativePosition
                _relativePosition = newValue
                relativePositionDidChange(from: oldValue)
            }
        }
    }
    
    /// The object's velocity.
    public var velocity: Vector {
        didSet {
            if velocity != oldValue {
                velocityDidChange(from: oldValue)
            }
        }
    }

    private var _relativePosition: Position
    private var _changes: GameWorldMemberChanges
    
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
        
        _relativePosition = .zero
        velocity = .zero
        
        _changes = []

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
            _changes = .none
        }
        return _changes
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
        _changes.insert(.state)
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
        _changes.insert(.state)
        observers.objectEnumerator().forEach { observer in
            (observer as? GameWorldMemberObserver)?.receive(event: .memberChange(with: .state), from: self, payload: nil)
        }
    }
    
    // MARK: - Events
    
    public override func broadcast(event: GameWorldMemberEvent, payload: Any? = nil) {
        state?.receive(event: event, from: self, payload: payload)
        super.broadcast(event: event, payload: payload)
    }
    
    internal func parentDidChange(from oldValue: GameWorldMember?) {
        guard let parent = parent else {
            _relativePosition = .zero
            return
        }
        
        // update absolute position
        position = Position(x: parent.position.x + relativePosition.x,
                            y: parent.position.y + relativePosition.y,
                            z: parent.position.z + relativePosition.z)
    }
    
    internal func relativePositionDidChange(from oldValue: Position) {
        // update absolute position
        let parentPosition = parent?.position ?? .zero
        position = Position(x: parentPosition.x + relativePosition.x,
                            y: parentPosition.y + relativePosition.y,
                            z: parentPosition.z + relativePosition.z)
    }
    
    internal override func positionDidChange(from oldValue: Position) {
        if let parent = parent {
            _relativePosition = Position(x: position.x - parent.position.x,
                                         y: position.y - parent.position.y,
                                         z: position.z - parent.position.z)
        }

        _changes.insert(.position)
        super.positionDidChange(from: oldValue)
    }
    
    private func velocityDidChange(from oldValue: Vector) {
        _changes.insert(.velocity)
        broadcast(event: .memberChange(with: .velocity), payload: oldValue)
    }
    
}
