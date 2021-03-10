//
//  GameObjectObserver.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/25/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameObjectObserver {

    func receive(event: GameWorldMemberEvent, from sender: GameObject, payload: Any?)

}

extension GameObjectObserver {
    
    public func receive(event: GameWorldMemberEvent, from sender: GameObject, payload: Any?) {
        
    }
    
}
