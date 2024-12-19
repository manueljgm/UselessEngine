//
//  GameObject.swift
//  UselessEngine
//
//  Created by Manny Martins on 11/21/14.
//  Copyright (c) 2014 Useless Robot. All rights reserved.
//

public class GameObject: GameWorldPositionable, GameWorldObservableSubject {

    // MARK: - Properties
    
    public private(set) weak var world: GameWorld?
    
    public private(set) weak var parent: GameObject? {
        didSet {
            if parent != oldValue {
                parentDidChange(from: oldValue)
            }
        }
    }
    
    /// Set to false to free positioning from parent.
    public var anchorToParent: Bool = true {
        didSet {
            positionDidChange(from: position)
        }
    }

    /// The object's state.
    public private(set) var state: GameObjectState? = nil
    
    /// The object's absolute position in the world.
    public var position: Position = .zero {
        didSet {
            if position != oldValue {
                positionDidChange(from: oldValue)
            }
        }
    }

    /// The object's relative position to its parent.
    public var relativePosition: Position {
        get {
            return relativePositionValue
        }
        set {
            if newValue != relativePositionValue {
                let oldValue = relativePositionValue
                relativePositionValue = newValue
                relativePositionDidChange(from: oldValue)
            }
        }
    }
        
    /// The object's velocity.
    public var velocity: Vector = .zero {
        didSet {
            if velocity != oldValue {
                velocityDidChange(from: oldValue)
            }
        }
    }
    
    /// The object's children.
    public internal(set) var children: Set<GameObject> = []

    // MARK: Components

    public var graphics: any GameWorldMemberGraphicsComponent<GameObject>
    public let audio: GameObjectAudioComponent?
    public let physics: GameObjectPhysicsComponent?
    public var input: GameObjectInputComponent?
    
    // MARK: Internal
    
    /// The object's observers.
    internal var observers: NSHashTable<AnyObject> = NSHashTable<AnyObject>.weakObjects()

    /// Represents whether the object is currently active.
    internal var isActive: Bool = false

    // MARK: Private
    
    private var flags: GameObjectFlags = []
    private var customAttributes: [GameWorldMemberCustomAttributeKey: Float] = [:]
    
    private var relativePositionValue: Position = .zero
    
    private let id = UUID()
        
    // MARK: - Init
    
    private static var inited: Int = 0
    
    public init(graphics graphicsComponent: any GameWorldMemberGraphicsComponent<GameObject>,
                audio audioComponent: GameObjectAudioComponent? = nil,
                physics physicsComponent: GameObjectPhysicsComponent? = nil,
                input inputComponent: GameObjectInputComponent? = nil)
    {
        graphics = graphicsComponent
        audio = audioComponent
        physics = physicsComponent
        input = inputComponent

        add(observer: graphics)
        if physics != nil {
            add(observer: physics!)
        }

        // set position again to result in the necessary call to the positionDidChange and to notify observers
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
    
    // MARK: - Public Methods
    
    // MARK: State

    public func enter(state newState: GameObjectState) {
        state?.willExit(with: self)
        state = newState
        state?.enter(with: self)
        // call super to skip notification to self's state
        broadcast(event: .memberChange(with: .state))
    }
    
    public func push(state newState: GameObjectState) {
        let newState = newState
        newState.fallbackState = state
        state?.willFallback(with: self)
        state = newState
        state?.enter(with: self)
        // call super to skip notification to self's state
        broadcast(event: .memberChange(with: .state))
    }
    
    public func exitState() {
        state?.willExit(with: self)
        state = state?.fallbackState
        state?.reenter(with: self)
        // call super to skip notification to self's state
        broadcast(event: .memberChange(with: .state))
    }

    // MARK: Relationships
    
    public func removeFromWorld() {
        world?.stageExit(of: self)
    }
    
    public func hasParent() -> Bool {
        return parent != nil
    }

    @discardableResult
    public func add(child: GameObject) -> Bool {
        if child.inWorld() || child.hasParent() {
            return false
        }
        
        children.insert(child)
        child.parent = self

        world?.stageEntry(of: child)
        
        return true
    }
    
    internal func removeFromParent() {
        parent?.children.remove(self)
        parent = nil
    }
    
    // MARK: Attributes
    
    public func isPhysical() -> Bool {
        return physics != nil
    }
    
    public func set(flags newFlags: GameObjectFlags) {
        flags.formUnion(newFlags)
    }
    
    public func contains(flags checkFlags: GameObjectFlags) -> Bool {
        return flags.contains(checkFlags)
    }

    public func clear(flags oldFlags: GameObjectFlags) {
        flags.remove(oldFlags)
    }

    public func set(_ value: Float, for key: GameWorldMemberCustomAttributeKey) {
        customAttributes[key] = value
        broadcast(event: .attributeChange(for: key), payload: value)
    }
    
    public func value(for key: GameWorldMemberCustomAttributeKey) -> Float {
        return customAttributes[key] ?? 0
    }

    // MARK: Observers
    
    public func add(observer: GameWorldMemberObserver) {
        observers.add(observer)
    }
    
    public func remove(observer: GameWorldMemberObserver) {
        observers.remove(observer)
    }
    
    public func broadcast(event: GameWorldMemberEvent, payload: Any? = nil) {
        state?.receive(event: event, from: self, payload: payload)
        observers.allObjects.forEach { observer in
            (observer as? GameWorldMemberObserver)?.receive(event: event, from: self, payload: payload)
        }
    }

    // MARK: Update
    
    public func update(_ dt: Float) {
        // update flag to represent that this member is now active
        isActive = true
        
        // update children
        children.forEach {
            $0.update(dt)
        }
        
        // update components
        graphics.update(with: self, dt: dt)
        physics?.update(with: self, dt: dt)
        state?.update(with: self, dt: dt)
        input?.update(with: self, dt: dt)
        
        // resolve any collisions
        world?.collisionGrid.resolve(for: self)

        // notify update to observers
        broadcast(event: .memberUpdate)
    }

    // MARK: - Internal Methods
    
    internal func set(world: GameWorld?) {
        self.world = world
    }
    
    // MARK: - Private Methods
    
    private func parentDidChange(from oldValue: GameObject?) {
        if let parent = parent, anchorToParent {
            // update absolute position
            position = Position(x: parent.position.x + relativePosition.x,
                                y: parent.position.y + relativePosition.y,
                                z: parent.position.z + relativePosition.z)
        } else {
            // update relative position to anchor of .zero
            relativePositionValue = position
        }
    }
    
    private func positionDidChange(from oldValue: Position) {
        if let parent = parent, anchorToParent {
            relativePositionValue = Position(x: position.x - parent.position.x,
                                         y: position.y - parent.position.y,
                                         z: position.z - parent.position.z)
        } else {
            relativePositionValue = position
        }

        children.filter(\.anchorToParent).forEach { child in
            child.position = Position(x: self.position.x + child.relativePosition.x,
                                      y: self.position.y + child.relativePosition.y,
                                      z: self.position.z + child.relativePosition.z)
        }
        
        broadcast(event: .memberChange(with: .position), payload: oldValue)
    }
    
    private func relativePositionDidChange(from oldValue: Position) {
        // get anchor position
        var anchorPosition: Position
        if let parent = parent, anchorToParent {
            anchorPosition = parent.position
        } else {
            anchorPosition = .zero
        }
        
        // update absolute position
        position = Position(x: anchorPosition.x + relativePosition.x,
                            y: anchorPosition.y + relativePosition.y,
                            z: anchorPosition.z + relativePosition.z)
    }

    private func velocityDidChange(from oldValue: Vector) {
        broadcast(event: .memberChange(with: .velocity), payload: oldValue)
    }
    
}

extension GameObject: Hashable {
    
    public static func == (lhs: GameObject, rhs: GameObject) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
