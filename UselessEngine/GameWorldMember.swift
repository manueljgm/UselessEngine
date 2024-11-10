//
//  GameWorldMember.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/16/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public class GameWorldMember: NSObject, GameWorldPositionable {

    // MARK: - Properties
    
    public internal(set) weak var world: GameWorld?
    
    public internal(set) weak var parent: GameWorldMember? {
        didSet {
            if parent != oldValue {
                parentDidChange(from: oldValue)
            }
        }
    }
    
    public var hasParent: Bool { parent != nil }
    
    /// Set to false to free positioning from parent.
    public var anchorToParent: Bool {
        didSet {
            positionDidChange(from: position)
        }
    }

    public var graphics: GameWorldMemberGraphicsComponent

    /// The member's absolute position in the world.
    public var position: Position {
        didSet {
            if position != oldValue {
                positionDidChange(from: oldValue)
            }
        }
    }

    /// The member's relative position to its parent.
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

    public internal(set) var children: Set<GameWorldMember>
    
    internal var isActive: Bool
    internal var inWorld: Bool { world != nil }
    internal var observers: NSHashTable<AnyObject>

    private var flags: GameWorldMemberFlags
    private var customAttributes: [GameWorldMemberCustomAttributeKey: Float]

    private var _relativePosition: Position

    // MARK: - Init
    
    public init(graphics: GameWorldMemberGraphicsComponent, position: Position = .zero) {
        anchorToParent = true
        
        self.graphics = graphics
        _relativePosition = .zero
        self.position = .zero
        self.children = []
        self.isActive = false
        self.observers = NSHashTable<AnyObject>.weakObjects()
        self.flags = []
        self.customAttributes = [:]
        
        super.init()
        
        add(observer: graphics)
        
        defer {
            // deferring setting this value will result in the necessary call to the position property's didSet
            self.position = position
        }
    }
    
    final public func set(flags newFlags: GameWorldMemberFlags) {
        flags.formUnion(newFlags)
    }
    
    final public func contains(flags checkFlags: GameWorldMemberFlags) -> Bool {
        return flags.contains(checkFlags)
    }

    final public func clear(flags oldFlags: GameWorldMemberFlags) {
        flags.remove(oldFlags)
    }    

    final public func set(_ value: Float, for key: GameWorldMemberCustomAttributeKey) {
        customAttributes[key] = value
        broadcast(event: .attributeChange(for: key), payload: value)
    }
    
    final public func value(for key: GameWorldMemberCustomAttributeKey) -> Float {
        return customAttributes[key] ?? 0
    }
    
    public func onUpdate(_ dt: Float) {
        // placeholder for overrides
    }
    
    final public func update(_ dt: Float) {
        // update flag to represent that this member is now active
        isActive = true

        // update children
        children.forEach {
            $0.update(dt)
        }
        
        // update graphics
        graphics.update(with: self, dt: dt)
        
        // placeholder for overrides
        onUpdate(dt)

        // notify update to observers
        broadcast(event: .memberUpdate)
    }

    final public func add(child: GameWorldMember) -> Bool {
        if child.inWorld || child.hasParent {
            return false
        }
        
        children.insert(child)
        child.parent = self

        world?.add(member: child)
        
        return true
    }
    
    final public func dismiss() {
        removeFromParent()
        world?.remove(member: self)
    }
    
    internal func removeFromParent() {
        parent?.children.remove(self)
        parent = nil
    }
    
    // MARK: - Events
    
    final public func add(observer: GameWorldMemberObserver) {
        observers.add(observer)
    }
    
    final public func remove(observer: GameWorldMemberObserver) {
        observers.remove(observer)
    }
    
    public func broadcast(event: GameWorldMemberEvent, payload: Any? = nil) {
        observers.allObjects.forEach { observer in
            (observer as? GameWorldMemberObserver)?.receive(event: event, from: self, payload: payload)
        }
    }
    
    private func parentDidChange(from oldValue: GameWorldMember?) {
        if let parent = parent, anchorToParent {
            // update absolute position
            position = Position(x: parent.position.x + relativePosition.x,
                                y: parent.position.y + relativePosition.y,
                                z: parent.position.z + relativePosition.z)
        } else {
            // update relative position to anchor of .zero
            _relativePosition = position
        }
    }
    
    private func positionDidChange(from oldValue: Position) {
        if let parent = parent, anchorToParent {
            _relativePosition = Position(x: position.x - parent.position.x,
                                         y: position.y - parent.position.y,
                                         z: position.z - parent.position.z)
        } else {
            _relativePosition = position
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

}
