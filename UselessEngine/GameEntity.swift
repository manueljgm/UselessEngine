//
//  GameEntity.swift
//  UselessEngine
//
//  Created by Manny Martins on 1/16/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

import UselessCommon

public protocol GameEntity: class, Updateable {
    var graphics: GameEntityGraphicsComponent? { get }
    var position: Position { get set }
}

