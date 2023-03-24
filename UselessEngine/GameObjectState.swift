//
//  GameObjectState.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/29/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public protocol GameObjectState: GameWorldUpdateable, GameWorldMemberObserver, GameObjectCollisionDelegate {

    var fallbackState: GameObjectState? { get set }

    func enter(with gameObject: GameObject)
    func handle(command: GameObjectCommand, on gameObject: GameObject, payload: AnyObject?)
    func willExit(with gameObject: GameObject)
    func reenter(with gameObject: GameObject)
    
}

extension GameObjectState {

    public func handle(command: GameObjectCommand, on gameObject: GameObject, payload: AnyObject?) {
        fallbackState?.handle(command: command, on: gameObject, payload: payload)
    }

    public func handleContact(between gameObject: GameObject, and otherObject: GameObject) {
        fallbackState?.handleContact(between: gameObject, and: otherObject)
    }
    
    public func handleCollision(between gameObject: GameObject, and otherObject: GameObject, withCorrection correctionOffset: Vector) {
        fallbackState?.handleCollision(between: gameObject, and: otherObject, withCorrection: correctionOffset)
    }
    
    public func willExit(with gameObject: GameObject) {
        
    }

    public func reenter(with gameObject: GameObject) {
        
    }

}
