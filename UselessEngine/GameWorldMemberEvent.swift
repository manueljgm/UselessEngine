//
//  GameWorldMemberEvent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/29/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public enum GameWorldMemberEvent {
    
    case memberChange(with: GameWorldMemberChanges)
    case memberEvent(byId: UUID)

}
