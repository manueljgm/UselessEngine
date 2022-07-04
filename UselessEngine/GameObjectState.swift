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
    func reenter(with gameObject: GameObject)
    func willExit(with gameObject: GameObject)
    
}

extension GameObjectState {

    public func handle(command: GameObjectCommand, on gameObject: GameObject, payload: AnyObject?) {

    }
    
    public func reenter(with gameObject: GameObject) {
        
    }
    
    public func willExit(with gameObject: GameObject) {
        
    }

}
