//
//  GameWorldDelegate.swift
//  UselessEngine
//
//  Created by Manny Martins on 3/15/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameWorldDelegate: GameWorldMemberObserver {
    
    func gameWorld(_ gameWorld: GameWorld, added member: any GameWorldPositionable)
    func gameWorld(_ gameWorld: GameWorld, removed member: any GameWorldPositionable)
    
}
