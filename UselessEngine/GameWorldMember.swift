//
//  GameWorldMember.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/16/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public class GameWorldMember: NSObject, GameWorldPositionable {

    public internal(set) weak var world: GameWorld?
    public var graphics: GameWorldMemberGraphicsComponent

    /// The member's absolute position in the world.
    public var position: Position {
        didSet {
            if position != oldValue {
                positionDidChange(from: oldValue)
            }
        }
    }

    public internal(set) var children: Set<GameObject>
    
    internal var isActive: Bool
    internal var inWorld: Bool { world != nil }
    internal var observers: NSHashTable<AnyObject>
    
    private var flags: GameWorldMemberFlags
    private var customAttributes: [GameWorldMemberCustomAttributeKey: Float]
    
    public init(graphics: GameWorldMemberGraphicsComponent, position: Position = .zero) {
        self.graphics = graphics
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
    
    public func set(flags newFlags: GameWorldMemberFlags) {
        flags.formUnion(newFlags)
    }
    
    public func contains(flags checkFlags: GameWorldMemberFlags) -> Bool {
        return flags.contains(checkFlags)
    }

    public func clear(flags oldFlags: GameWorldMemberFlags) {
        flags.remove(oldFlags)
    }    

    public func set(_ value: Float, for key: GameWorldMemberCustomAttributeKey) {
        customAttributes[key] = value
        broadcast(event: .attributeChange(for: key), payload: value)
    }
    
    public func value(for key: GameWorldMemberCustomAttributeKey) -> Float {
        return customAttributes[key] ?? 0
    }
    
    public func update(_ dt: Float) {
        // update flag to represent that this member is now active
        isActive = true

        // update children
        children.forEach {
            $0.update(dt)
        }
        
        // update graphics
        graphics.update(with: self, dt: dt)
    }

    public func add(child: GameObject) -> Bool {
        if child.inWorld || child.hasParent {
            return false
        }
        
        children.insert(child)
        child.parent = self

        world?.add(member: child)
        
        return true
    }
    
    // MARK: - Events
    
    public func add(observer: GameWorldMemberObserver) {
        observers.add(observer)
    }
    
    public func broadcast(event: GameWorldMemberEvent, payload: Any? = nil) {
        observers.objectEnumerator().forEach { observer in
            (observer as? GameWorldMemberObserver)?.receive(event: event, from: self, payload: payload)
        }
    }
    
    public func remove(observer: GameWorldMemberObserver) {
        observers.remove(observer)
    }

    internal func positionDidChange(from oldValue: Position) {
        children.forEach { child in
            child.position = Position(x: self.position.x + child.relativePosition.x,
                                      y: self.position.y + child.relativePosition.y,
                                      z: self.position.z + child.relativePosition.z)
        }
        
        broadcast(event: .memberChange(with: .position), payload: oldValue)
    }

}
