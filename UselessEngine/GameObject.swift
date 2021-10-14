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

    public let audio: GameObjectAudioComponent?
    public let physics: GameObjectPhysicsComponent
    public var input: GameObjectInputComponent?
    
    /// The object's position.
    override public var position: Position {
        didSet {
            if (position != oldValue) {
                changes.insert(.position)
                broadcast(event: .memberChange(with: .position), payload: oldValue)
            }
        }
    }
    
    /// The object's velocity.
    public var velocity: Vector {
        didSet {
            if (velocity != oldValue) {
                changes.insert(.velocity)
                broadcast(event: .memberChange(with: .velocity), payload: oldValue)
            }
        }
    }

    private var changes: GameWorldMemberChanges = []
    private var observers: NSHashTable<AnyObject>
    
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
        
        observers = NSHashTable<AnyObject>.weakObjects()
        
        super.init(graphics: graphicsComponent)
        
        add(observer: graphics)
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

    public override func update(_ dt: Float, in world: GameWorld) -> GameWorldMemberChanges {
        physics.update(with: self, in: world, dt: dt)
        graphics.update(with: self, in: world, dt: dt)
        state?.update(with: self, in: world, dt: dt)
        input?.update(with: self, dt: dt)

        defer {
            changes = .none
        }
        return changes
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
    
    public func add(observer: GameWorldMemberObserver) {
        observers.add(observer)
    }
    
    public func broadcast(event: GameWorldMemberEvent, payload: Any? = nil) {
        state?.receive(event: event, from: self, payload: payload)
        observers.objectEnumerator().forEach { observer in
            (observer as? GameWorldMemberObserver)?.receive(event: event, from: self, payload: payload)
        }
    }
    
    public func remove(observer: GameWorldMemberObserver) {
        observers.remove(observer)
    }
    
}
