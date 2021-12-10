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
    
    public var position: Position {
        didSet {
            if position != oldValue {
                positionDidChange(from: oldValue)
            }
        }
    }

    public internal(set) var children: Set<GameObject>

    internal var observers: NSHashTable<AnyObject>
    
    public init(graphics: GameWorldMemberGraphicsComponent, position: Position = .zero) {
        self.graphics = graphics
        self.position = .zero
        self.children = []
        self.observers = NSHashTable<AnyObject>.weakObjects()

        super.init()
        
        add(observer: graphics)
        
        defer {
            // deferring setting this value will result in the necessary call to the position property's didSet
            self.position = position
        }
    }
    
    public func update(_ dt: Float) -> GameWorldMemberChanges {
        // update graphics
        graphics.update(with: self, dt: dt)

        // there are no significant changes to report
        return .none
    }

    public func add(child: GameObject) -> Bool {
        guard child.parent == nil else {
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
        broadcast(event: .memberChange(with: .position), payload: oldValue)
    }

}
