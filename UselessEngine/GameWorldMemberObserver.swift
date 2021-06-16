//
//  GameWorldMemberObserver.swift
//  UselessEngine
//
//  Created by Manny Martins on 7/30/15.
//  Copyright (c) 2015 Useless Robot. All rights reserved.
//

public protocol GameWorldMemberObserver: AnyObject {

    func receive(event: GameWorldMemberEvent, from sender: GameWorldMember, payload: Any?)

}

extension GameWorldMemberObserver {
    
    public func receive(event: GameWorldMemberEvent, from sender: GameWorldMember, payload: Any?) {
        
    }
    
}
