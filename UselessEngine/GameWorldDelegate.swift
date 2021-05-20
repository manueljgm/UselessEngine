//
//  GameWorldDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 3/15/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameWorldDelegate: AnyObject, GameObjectObserver {
    
    func gameWorld(_ gameWorld: GameWorld, added gameWorldMember: GameWorldMember)
    func gameWorld(_ gameWorld: GameWorld, removed gameWorldMember: GameWorldMember)
    
}
