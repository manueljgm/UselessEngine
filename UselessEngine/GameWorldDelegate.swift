//
//  GameWorldDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 3/15/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameWorldDelegate: GameWorldMemberObserver {
    
    func gameWorld(_ gameWorld: GameWorld, added gameWorldMember: GameWorldMember)
    func gameWorld(_ gameWorld: GameWorld, removed gameWorldMember: GameWorldMember)
    func gameWorld(_ gameWorld: GameWorld, updated gameObject: GameObject)
    
}

extension GameWorldDelegate {
    
    public func gameWorld(_ gameWorld: GameWorld, updated gameObject: GameObject) {
        
    }
    
}
