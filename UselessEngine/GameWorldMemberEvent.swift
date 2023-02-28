//
//  GameWorldMemberEvent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/29/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

public enum GameWorldMemberEvent: Equatable {

    case memberChange(with: GameWorldMemberChanges)
    case memberUpdate
    case memberEvent(byId: UUID)
    case attributeChange(for: GameWorldMemberCustomAttributeKey)
    
}
