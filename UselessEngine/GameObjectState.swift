//
//  GameObjectState.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/29/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public protocol GameObjectState: GameWorldMemberObserver {

    var id: UUID { get }
    
    var isOutOfAction: Bool { get }
    
    var fallbackState: GameObjectState? { get set }

    func enter(with gameObject: GameObject)
    func handle(command: GameObjectCommand, on gameObject: GameObject, payload: AnyObject?)
    func update(with gameObject: GameObject, in world: GameWorld, dt: Float)
    func reset(with gameObject: GameObject)
    
}

extension GameObjectState {

    public func handle(command: GameObjectCommand, on gameObject: GameObject, payload: AnyObject?) {

    }
    
    public func reset(with gameObject: GameObject) {
        
    }

}
