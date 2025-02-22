//
//  GameWorld+GameWorldMemberObserver.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/6/24.
//  Copyright © 2024 Useless Robot. All rights reserved.
//

extension GameWorld: GameWorldMemberObserver {
    
    public func receive(event: GameWorldMemberEvent, from sender: any GameWorldPositionable, payload: Any?) {
        delegate?.receive(event: event, from: sender, payload: payload)
    }
    
}
