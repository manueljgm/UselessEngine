//
//  GameWorldMember.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/16/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

public protocol GameWorldMember: GameWorldPositionable {

    var graphics: GameWorldMemberGraphicsComponent { get }

    func update(_ dt: Float, in world: GameWorld) -> GameWorldMemberChanges

}
