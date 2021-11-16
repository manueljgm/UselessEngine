//
//  GameWorldObserverSubject.swift
//  UselessEngine
//
//  Created by Manny Martins on 10/26/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

protocol GameWorldObserverSubject {

    func add(observer: GameWorldMemberObserver)
    func broadcast(event: GameWorldMemberEvent, payload: Any?)
    func remove(observer: GameWorldMemberObserver)
    
}
