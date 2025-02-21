//
//  GameWorldMemberEvent.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/29/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import Foundation

public enum GameWorldMemberEvent: Equatable {

    case memberUpdate(with: GameWorldMemberChanges)
    case memberEvent(byId: UUID)
    case attributeChange(for: GameWorldMemberCustomAttributeKey)
    
}
