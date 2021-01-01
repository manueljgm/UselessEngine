//
//  GameObjectState.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/29/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public protocol GameObjectState: Observer {
    var isOutOfAction: Bool { get }
    var fallbackState: GameObjectState? { get set }
    func enter(with gameObject: GameObject)
    func handle(command: GameObjectCommand, for gameObject: GameObject)
    func update(with gameObject: GameObject, in world: GameWorld, dt: Float)
    func reset(with gameObject: GameObject)
}

extension GameObjectState
{
    public func handle(command: GameObjectCommand, for gameObject: GameObject) {
        
    }
    
    public func reset(with gameObject: GameObject) {
        
    }
}
